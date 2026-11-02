import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/checkin_record.dart';
import '../../../models/membership_plan.dart';
import '../../../models/qr_checkin_token.dart';
import '../../../services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../exercises/providers/exercise_provider.dart';
import '../models/admin_role.dart';
import '../models/admin_stats.dart';
import '../models/payment_transaction.dart';
import '../repositories/admin_repository.dart';
import '../repositories/firestore_admin_repository.dart';
import '../repositories/local_admin_repository.dart';

// 1. Current Active Role in Admin Portal
final currentAdminRoleProvider = StateProvider<UserRole>((ref) {
  // Default to Administrator for immediate operational control
  return UserRole.admin;
});

// 2. Admin Repository Provider
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final local = LocalAdminRepository(prefs);

  if (FirebaseService.isInitialized) {
    try {
      return FirestoreAdminRepository(
        FirebaseFirestore.instance,
        local,
      );
    } catch (_) {
      return local;
    }
  }
  return local;
});

// 3. Admin Overview Dashboard Stats Stream
final adminDashboardStatsProvider = StreamProvider.autoDispose<AdminStats>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.watchDashboardStats();
});

// 4. Member Management Providers
final memberSearchQueryProvider = StateProvider<String>((ref) => '');
final memberStatusFilterProvider = StateProvider<String>((ref) => 'all'); // 'all', 'active', 'expired', 'suspended'

final allMembersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getAllMembers();
});

final filteredMembersProvider =
    Provider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final membersAsync = ref.watch(allMembersProvider);
  final query = ref.watch(memberSearchQueryProvider).toLowerCase().trim();
  final filter = ref.watch(memberStatusFilterProvider);

  return membersAsync.maybeWhen(
    data: (members) {
      return members.where((m) {
        // Filter Status
        if (filter != 'all') {
          if (m['status'] != filter) return false;
        }

        // Search Query
        if (query.isNotEmpty) {
          final name = (m['displayName'] as String? ?? '').toLowerCase();
          final email = (m['email'] as String? ?? '').toLowerCase();
          final code = (m['memberCode'] as String? ?? '').toLowerCase();
          return name.contains(query) ||
              email.contains(query) ||
              code.contains(query);
        }

        return true;
      }).toList();
    },
    orElse: () => [],
  );
});

// 5. Payment Verification Providers
final pendingPaymentsFilterProvider = StateProvider<String?>((ref) => 'pending');

final adminPaymentsListProvider =
    FutureProvider.autoDispose<List<PaymentTransaction>>((ref) async {
  final filter = ref.watch(pendingPaymentsFilterProvider);
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getAllPayments(statusFilter: filter);
});

// 6. Gym Check-In List Provider
final adminCheckinsDateFilterProvider = StateProvider<DateTime?>((ref) => null);

final adminCheckinsListProvider =
    FutureProvider.autoDispose<List<CheckInRecord>>((ref) async {
  final date = ref.watch(adminCheckinsDateFilterProvider);
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getCheckins(date: date);
});

// 7. Membership Plans Provider
final adminPlansListProvider =
    FutureProvider.autoDispose<List<MembershipPlan>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getMembershipPlans();
});

// 8. Admin Operations Action Controller
class AdminActionController {
  final Ref _ref;

  AdminActionController(this._ref);

  Future<void> approvePayment(String paymentId) async {
    final repo = _ref.read(adminRepositoryProvider);
    final user = await _ref.read(currentUserProfileProvider.future);
    final adminUid = user?.uid ?? 'admin_super';

    await repo.approvePayment(paymentId, adminUid);
    _ref.invalidate(adminPaymentsListProvider);
    _ref.invalidate(allMembersProvider);
    _ref.invalidate(adminDashboardStatsProvider);
  }

  Future<void> rejectPayment(String paymentId, String reason) async {
    final repo = _ref.read(adminRepositoryProvider);
    final user = await _ref.read(currentUserProfileProvider.future);
    final adminUid = user?.uid ?? 'admin_super';

    await repo.rejectPayment(paymentId, adminUid, reason);
    _ref.invalidate(adminPaymentsListProvider);
    _ref.invalidate(adminDashboardStatsProvider);
  }

  Future<void> updateMemberStatus({
    required String userId,
    required String status,
    DateTime? customExpiry,
    String? adminNotes,
  }) async {
    final repo = _ref.read(adminRepositoryProvider);
    await repo.updateMemberStatus(
      userId,
      status,
      customExpiry: customExpiry,
      adminNotes: adminNotes,
    );
    _ref.invalidate(allMembersProvider);
    _ref.invalidate(adminDashboardStatsProvider);
  }

  Future<QrValidationResult> processQrScan({
    required String qrPayload,
    required String gateName,
  }) async {
    final repo = _ref.read(adminRepositoryProvider);
    final user = await _ref.read(currentUserProfileProvider.future);
    final staffUid = user?.displayName ?? 'Petugas Turnstile';

    final result = await repo.verifyAndProcessQrCheckin(
      qrPayload: qrPayload,
      gateName: gateName,
      staffUid: staffUid,
    );

    _ref.invalidate(adminCheckinsListProvider);
    _ref.invalidate(adminDashboardStatsProvider);
    return result;
  }

  Future<void> savePlan(MembershipPlan plan) async {
    final repo = _ref.read(adminRepositoryProvider);
    await repo.saveMembershipPlan(plan);
    _ref.invalidate(adminPlansListProvider);
  }

  Future<int> bulkImportExercisesToFirestore() async {
    final exerciseRepo = _ref.read(exerciseRepositoryProvider);
    final exercises = await exerciseRepo.getExercises(limit: 500);
    final adminRepo = _ref.read(adminRepositoryProvider);

    final count = await adminRepo.bulkImportExercises(exercises);
    _ref.invalidate(adminDashboardStatsProvider);
    return count;
  }
}

final adminActionControllerProvider = Provider<AdminActionController>((ref) {
  return AdminActionController(ref);
});
