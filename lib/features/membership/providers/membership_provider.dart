import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/checkin_record.dart';
import '../../../models/membership_plan.dart';
import '../../../models/qr_checkin_token.dart';
import '../../../models/user_membership.dart';
import '../../../repositories/firestore_membership_repository.dart';
import '../../../repositories/local_membership_repository.dart';
import '../../../repositories/membership_repository.dart';
import '../../../services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';

// 1. Membership Repository Provider
final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final localRepo = LocalMembershipRepository(prefs);

  if (FirebaseService.isInitialized) {
    try {
      return FirestoreMembershipRepository(
        FirebaseFirestore.instance,
        localRepo,
      );
    } catch (_) {
      return localRepo;
    }
  }
  return localRepo;
});

// 2. Active Membership Stream Provider
final activeMembershipProvider =
    StreamProvider.autoDispose<UserMembership?>((ref) {
  final userProfileAsync = ref.watch(currentUserProfileProvider);
  final repo = ref.watch(membershipRepositoryProvider);

  return userProfileAsync.when(
    data: (profile) {
      if (profile == null) return Stream.value(null);
      return repo.watchActiveMembership(profile.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// 3. Check-In History Provider
final checkInHistoryProvider =
    FutureProvider.autoDispose<List<CheckInRecord>>((ref) async {
  final userProfile = await ref.watch(currentUserProfileProvider.future);
  if (userProfile == null) return [];

  final repo = ref.watch(membershipRepositoryProvider);
  return repo.getCheckInHistory(userProfile.uid);
});

// 4. Membership Action Controller
class MembershipActionController {
  final Ref _ref;

  MembershipActionController(this._ref);

  Future<void> activatePlan({
    required MembershipPlan plan,
    String paymentMethod = 'QRIS Instant',
  }) async {
    final profile = await _ref.read(currentUserProfileProvider.future);
    if (profile == null) throw Exception('Pengguna tidak terautentikasi');

    final now = DateTime.now();
    final expiry = plan.durationDays == 1
        ? now.add(const Duration(hours: 24))
        : now.add(Duration(days: plan.durationDays));

    final membershipId = 'mem_${DateTime.now().millisecondsSinceEpoch}';
    final randomCode = 'FS-${(profile.uid.hashCode.abs() % 90000) + 10000}';

    final membership = UserMembership(
      id: membershipId,
      userId: profile.uid,
      planId: plan.id,
      planName: plan.name,
      startDate: now,
      expiryDate: expiry,
      pricePaid: plan.price,
      status: 'active',
      paymentMethod: paymentMethod,
      memberCode: randomCode,
    );

    final repo = _ref.read(membershipRepositoryProvider);
    await repo.activateMembership(membership);
    _ref.invalidate(activeMembershipProvider);
  }

  Future<void> cancelMembership() async {
    final profile = await _ref.read(currentUserProfileProvider.future);
    if (profile == null) return;

    final repo = _ref.read(membershipRepositoryProvider);
    await repo.cancelMembership(profile.uid);
    _ref.invalidate(activeMembershipProvider);
  }

  Future<CheckInRecord> recordTurnstileCheckIn({
    required String location,
    String notes = 'Check-in Gate Berhasil',
  }) async {
    final profile = await _ref.read(currentUserProfileProvider.future);
    final membership = await _ref.read(activeMembershipProvider.future);

    if (profile == null) {
      throw Exception('Pengguna tidak terautentikasi');
    }

    final record = CheckInRecord(
      id: 'chk_${DateTime.now().millisecondsSinceEpoch}',
      userId: profile.uid,
      membershipId: membership?.id ?? 'guest',
      planName: membership?.planName ?? 'Pengunjung',
      timestamp: DateTime.now(),
      location: location,
      status: membership != null && membership.isActive ? 'granted' : 'denied',
      notes: notes,
    );

    final repo = _ref.read(membershipRepositoryProvider);
    final saved = await repo.recordCheckIn(record);
    _ref.invalidate(checkInHistoryProvider);
    return saved;
  }
}

final membershipActionControllerProvider =
    Provider<MembershipActionController>((ref) {
  return MembershipActionController(ref);
});

// 5. Dynamic 60-Second Rotating QR State
class DynamicQrState {
  final QrCheckinToken token;
  final int secondsRemaining;
  final double progress; // 1.0 (baru) -> 0.0 (habis)

  const DynamicQrState({
    required this.token,
    required this.secondsRemaining,
    required this.progress,
  });

  DynamicQrState copyWith({
    QrCheckinToken? token,
    int? secondsRemaining,
    double? progress,
  }) {
    return DynamicQrState(
      token: token ?? this.token,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      progress: progress ?? this.progress,
    );
  }
}

class DynamicQrNotifier extends StateNotifier<DynamicQrState?> {
  final Ref _ref;
  Timer? _timer;

  DynamicQrNotifier(this._ref) : super(null) {
    _init();
  }

  void _init() {
    _ref.listen<AsyncValue<UserMembership?>>(activeMembershipProvider,
        (prev, next) {
      next.whenData((membership) {
        if (membership != null && membership.isActive) {
          _generateNewToken(membership);
          _startTimer();
        } else {
          _stopTimer();
          state = null;
        }
      });
    });

    final currentMembership = _ref.read(activeMembershipProvider).valueOrNull;
    if (currentMembership != null && currentMembership.isActive) {
      _generateNewToken(currentMembership);
      _startTimer();
    }
  }

  void _generateNewToken(UserMembership membership) {
    final token = QrCheckinToken.create(
      userId: membership.userId,
      membershipId: membership.id,
      memberCode: membership.generatedCode,
    );

    state = DynamicQrState(
      token: token,
      secondsRemaining: QrCheckinToken.tokenTtlSeconds,
      progress: 1.0,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state == null) {
        t.cancel();
        return;
      }

      final rem = state!.token.secondsRemaining;
      if (rem <= 0) {
        // Token habis, putar token baru otomatis!
        final currentMembership =
            _ref.read(activeMembershipProvider).valueOrNull;
        if (currentMembership != null && currentMembership.isActive) {
          _generateNewToken(currentMembership);
        } else {
          _stopTimer();
        }
      } else {
        final prog = rem / QrCheckinToken.tokenTtlSeconds;
        state = state!.copyWith(
          secondsRemaining: rem,
          progress: prog,
        );
      }
    });
  }

  void regenerateNow() {
    final currentMembership = _ref.read(activeMembershipProvider).valueOrNull;
    if (currentMembership != null && currentMembership.isActive) {
      _generateNewToken(currentMembership);
      _startTimer();
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

final dynamicQrProvider =
    StateNotifierProvider.autoDispose<DynamicQrNotifier, DynamicQrState?>(
        (ref) {
  return DynamicQrNotifier(ref);
});
