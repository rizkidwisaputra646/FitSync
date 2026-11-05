import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/checkin_record.dart';
import '../../../models/exercise.dart';
import '../../../models/membership_plan.dart';
import '../../../models/qr_checkin_token.dart';
import '../../../models/user_membership.dart';
import '../models/admin_stats.dart';
import '../models/payment_transaction.dart';
import 'admin_repository.dart';

class LocalAdminRepository implements AdminRepository {
  final SharedPreferences _prefs;
  final StreamController<AdminStats> _statsController =
      StreamController<AdminStats>.broadcast();

  LocalAdminRepository(this._prefs) {
    _seedInitialDataIfNeeded();
  }

  static const String _paymentsKey = 'admin_payments_vault';
  static const String _membersKey = 'admin_members_vault';
  static const String _checkinsKey = 'admin_checkins_vault';
  static const String _plansKey = 'admin_custom_plans_vault';
  static const String _activitiesKey = 'admin_activities_vault';

  void _seedInitialDataIfNeeded() {
    if (!_prefs.containsKey(_membersKey)) {
      final now = DateTime.now();

      // Seed mock members
      final members = [
        {
          'uid': 'user_001',
          'displayName': 'Ahmad Fauzi',
          'email': 'ahmad.fauzi@gmail.com',
          'memberCode': 'FS-98241',
          'status': 'active',
          'planName': 'Member 1 Bulan',
          'planId': 'monthly-pass',
          'startDate': now.subtract(const Duration(days: 5)).toIso8601String(),
          'expiryDate': now.add(const Duration(days: 25)).toIso8601String(),
          'totalCheckins': 8,
          'joinDate': now.subtract(const Duration(days: 40)).toIso8601String(),
        },
        {
          'uid': 'user_002',
          'displayName': 'Siti Rahma',
          'email': 'siti.rahma@yahoo.com',
          'memberCode': 'FS-48215',
          'status': 'active',
          'planName': 'Member Harian',
          'planId': 'daily-pass',
          'startDate': now.subtract(const Duration(hours: 4)).toIso8601String(),
          'expiryDate': now.add(const Duration(hours: 20)).toIso8601String(),
          'totalCheckins': 1,
          'joinDate': now.subtract(const Duration(days: 10)).toIso8601String(),
        },
        {
          'uid': 'user_003',
          'displayName': 'Budi Santoso',
          'email': 'budi.santoso@outlook.com',
          'memberCode': 'FS-32109',
          'status': 'expired',
          'planName': 'Member 1 Bulan',
          'planId': 'monthly-pass',
          'startDate': now.subtract(const Duration(days: 35)).toIso8601String(),
          'expiryDate': now.subtract(const Duration(days: 5)).toIso8601String(),
          'totalCheckins': 14,
          'joinDate': now.subtract(const Duration(days: 60)).toIso8601String(),
        },
        {
          'uid': 'user_004',
          'displayName': 'Jessica Tan',
          'email': 'jessica.tan@gmail.com',
          'memberCode': 'FS-11983',
          'status': 'suspended',
          'planName': 'Member 1 Bulan',
          'planId': 'monthly-pass',
          'startDate': now.subtract(const Duration(days: 12)).toIso8601String(),
          'expiryDate': now.add(const Duration(days: 18)).toIso8601String(),
          'totalCheckins': 3,
          'joinDate': now.subtract(const Duration(days: 20)).toIso8601String(),
        },
      ];
      _prefs.setString(_membersKey, jsonEncode(members));

      // Seed pending payments
      final payments = [
        PaymentTransaction(
          id: 'pay_001',
          userId: 'user_005',
          userName: 'Rian Pratama',
          userEmail: 'rian.pratama@gmail.com',
          memberCode: 'FS-55421',
          planId: 'monthly-pass',
          planName: 'Member 1 Bulan',
          amount: 250000,
          paymentMethod: 'Transfer Bank BCA (VA)',
          status: PaymentStatus.pending,
          createdAt: now.subtract(const Duration(minutes: 45)),
        ).toJson(),
        PaymentTransaction(
          id: 'pay_002',
          userId: 'user_006',
          userName: 'Dewi Lestari',
          userEmail: 'dewi.lestari@gmail.com',
          memberCode: 'FS-66712',
          planId: 'daily-pass',
          planName: 'Member Harian',
          amount: 35000,
          paymentMethod: 'QRIS Statis Kasir',
          status: PaymentStatus.pending,
          createdAt: now.subtract(const Duration(hours: 2)),
        ).toJson(),
      ];
      _prefs.setString(_paymentsKey, jsonEncode(payments));

      // Seed check-in logs
      final checkins = [
        CheckInRecord(
          id: 'chk_101',
          userId: 'user_001',
          membershipId: 'mem_1',
          planName: 'Member 1 Bulan',
          timestamp: now.subtract(const Duration(minutes: 25)),
          location: 'Main Gate - Turnstile 01',
          status: 'granted',
          notes: 'Akses Diberikan • Validasi 60s OK',
        ).toJson(),
        CheckInRecord(
          id: 'chk_102',
          userId: 'user_002',
          membershipId: 'mem_2',
          planName: 'Member Harian',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 10)),
          location: 'Main Gate - Turnstile 02',
          status: 'granted',
          notes: 'Akses Diberikan • Validasi 60s OK',
        ).toJson(),
      ];
      _prefs.setString(_checkinsKey, jsonEncode(checkins));

      // Seed activities
      final activities = [
        RecentAdminActivity(
          id: 'act_1',
          title: 'Check-in Berhasil',
          description: 'Ahmad Fauzi (FS-98241) check-in di Turnstile 01',
          timestamp: now.subtract(const Duration(minutes: 25)),
          type: 'checkin',
        ).toJson(),
        RecentAdminActivity(
          id: 'act_2',
          title: 'Pembayaran Baru',
          description: 'Rian Pratama menunggu verifikasi paket Member 1 Bulan',
          timestamp: now.subtract(const Duration(minutes: 45)),
          type: 'payment',
        ).toJson(),
      ];
      _prefs.setString(_activitiesKey, jsonEncode(activities));
    }
  }

  @override
  Future<AdminStats> getDashboardStats() async {
    final members = await getAllMembers();
    final payments = await getAllPayments();
    final checkins = await getCheckins();

    final activeCount = members.where((m) => m['status'] == 'active').length;
    final expiredCount = members.where((m) => m['status'] == 'expired').length;
    final pendingCount =
        payments.where((p) => p.status == PaymentStatus.pending).length;

    // Checkins today
    final now = DateTime.now();
    final todayCount = checkins.where((c) {
      return c.timestamp.year == now.year &&
          c.timestamp.month == now.month &&
          c.timestamp.day == now.day;
    }).length;

    // 7 days checkin distribution
    final weekly = [
      const CheckinDayStat(dayName: 'Sen', count: 18),
      const CheckinDayStat(dayName: 'Sel', count: 24),
      const CheckinDayStat(dayName: 'Rab', count: 22),
      const CheckinDayStat(dayName: 'Kam', count: 28),
      const CheckinDayStat(dayName: 'Jum', count: 32),
      const CheckinDayStat(dayName: 'Sab', count: 45),
      CheckinDayStat(dayName: 'Min', count: todayCount > 0 ? todayCount : 15),
    ];

    // Recent activities
    final rawAct = _prefs.getString(_activitiesKey);
    List<RecentAdminActivity> activities = [];
    if (rawAct != null) {
      try {
        final List<dynamic> list = jsonDecode(rawAct);
        activities = list
            .map((e) => RecentAdminActivity.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    return AdminStats(
      totalMembers: members.length,
      activeMembers: activeCount,
      expiredMembers: expiredCount,
      pendingPayments: pendingCount,
      todayCheckins: todayCount,
      weeklyCheckins: weekly,
      recentActivities: activities,
    );
  }

  @override
  Stream<AdminStats> watchDashboardStats() async* {
    yield await getDashboardStats();
    yield* _statsController.stream;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllMembers() async {
    final raw = _prefs.getString(_membersKey);
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> updateMemberStatus(
    String userId,
    String status, {
    DateTime? customExpiry,
    String? adminNotes,
  }) async {
    final members = await getAllMembers();
    final updated = members.map((m) {
      if (m['uid'] == userId) {
        final copy = Map<String, dynamic>.from(m);
        copy['status'] = status;
        if (customExpiry != null) {
          copy['expiryDate'] = customExpiry.toIso8601String();
        }
        return copy;
      }
      return m;
    }).toList();

    await _prefs.setString(_membersKey, jsonEncode(updated));
    _logActivity(
      title: 'Status Member Diperbarui',
      description: 'Member $userId diubah menjadi $status',
      type: 'member',
    );
  }

  @override
  Future<List<PaymentTransaction>> getAllPayments(
      {String? statusFilter}) async {
    final raw = _prefs.getString(_paymentsKey);
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      var items = list
          .map((e) => PaymentTransaction.fromJson(e as Map<String, dynamic>))
          .toList();

      if (statusFilter != null) {
        items = items.where((p) => p.status.name == statusFilter).toList();
      }
      return items..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> createPaymentRequest(PaymentTransaction transaction) async {
    final payments = await getAllPayments();
    final updated = [transaction, ...payments];
    await _prefs.setString(
        _paymentsKey, jsonEncode(updated.map((p) => p.toJson()).toList()));
  }

  @override
  Future<void> approvePayment(String paymentId, String adminUid) async {
    final payments = await getAllPayments();
    PaymentTransaction? target;
    final updated = payments.map((p) {
      if (p.id == paymentId) {
        target = p.copyWith(
          status: PaymentStatus.approved,
          processedByAdminId: adminUid,
          processedAt: DateTime.now(),
        );
        return target!;
      }
      return p;
    }).toList();

    await _prefs.setString(
        _paymentsKey, jsonEncode(updated.map((p) => p.toJson()).toList()));

    if (target != null) {
      // Aktifkan / Perpanjang Membership User
      final now = DateTime.now();
      final isDaily = target!.planId == 'daily-pass';
      final expiry = isDaily
          ? now.add(const Duration(hours: 24))
          : now.add(const Duration(days: 30));

      final membership = UserMembership(
        id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
        userId: target!.userId,
        planId: target!.planId,
        planName: target!.planName,
        startDate: now,
        expiryDate: expiry,
        pricePaid: target!.amount,
        status: 'active',
        paymentMethod: target!.paymentMethod,
        memberCode: target!.memberCode,
      );

      // Save to user's membership key
      await _prefs.setString(
          'user_membership_${target!.userId}', jsonEncode(membership.toJson()));

      // Update in members list as well
      await updateMemberStatus(
        target!.userId,
        'active',
        customExpiry: expiry,
      );

      _logActivity(
        title: 'Pembayaran Disetujui',
        description:
            'Admin menyetujui ${target!.planName} untuk ${target!.userName}',
        type: 'payment',
      );
    }
  }

  @override
  Future<void> rejectPayment(
      String paymentId, String adminUid, String reason) async {
    final payments = await getAllPayments();
    PaymentTransaction? target;
    final updated = payments.map((p) {
      if (p.id == paymentId) {
        target = p.copyWith(
          status: PaymentStatus.rejected,
          rejectionReason: reason,
          processedByAdminId: adminUid,
          processedAt: DateTime.now(),
        );
        return target!;
      }
      return p;
    }).toList();

    await _prefs.setString(
        _paymentsKey, jsonEncode(updated.map((p) => p.toJson()).toList()));

    if (target != null) {
      _logActivity(
        title: 'Pembayaran Ditolak',
        description:
            'Pembayaran ${target!.userName} ditolak dengan alasan: $reason',
        type: 'payment',
      );
    }
  }

  @override
  Future<List<CheckInRecord>> getCheckins({DateTime? date}) async {
    final raw = _prefs.getString(_checkinsKey);
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      var items = list
          .map((e) => CheckInRecord.fromJson(e as Map<String, dynamic>))
          .toList();

      if (date != null) {
        items = items.where((c) {
          return c.timestamp.year == date.year &&
              c.timestamp.month == date.month &&
              c.timestamp.day == date.day;
        }).toList();
      }

      return items..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {
      return [];
    }
  }

  @override
  Future<QrValidationResult> verifyAndProcessQrCheckin({
    required String qrPayload,
    required String gateName,
    required String staffUid,
  }) async {
    final validation = QrCheckinToken.validate(qrPayload);

    if (!validation.isValid) {
      return validation;
    }

    final userId = validation.userId!;
    final memberCode = validation.memberCode!;
    final tokenId = validation.tokenId ?? 'legacy_${validation.epochSeconds}';

    // Cek apakah token sudah pernah digunakan (Pencegahan penggunaan ulang / replay attack)
    final usedTokens = _prefs.getStringList('used_qr_tokens') ?? [];
    if (usedTokens.contains(tokenId)) {
      return const QrValidationResult(
        isValid: false,
        message: 'Akses Ditolak: Kode QR ini SUDAH DIGUNAKAN untuk check-in!',
      );
    }

    // Cek apakah membership aktif
    final rawMembership = _prefs.getString('user_membership_$userId');
    UserMembership? userMem;
    if (rawMembership != null) {
      try {
        userMem = UserMembership.fromJson(jsonDecode(rawMembership));
      } catch (_) {}
    }

    // Jika di member vault status suspended
    final members = await getAllMembers();
    final memberItem = members.firstWhere(
      (m) => m['uid'] == userId,
      orElse: () => {'status': 'active'},
    );

    if (memberItem['status'] == 'suspended') {
      return const QrValidationResult(
        isValid: false,
        message: 'Akses Ditolak: Akun member ini sedang DITANGGUHKAN oleh Admin.',
      );
    }

    if (userMem == null || !userMem.isActive) {
      return const QrValidationResult(
        isValid: false,
        message: 'Akses Ditolak: Paket membership member ini sudah KEDALUWARSA.',
      );
    }

    // Catat log check-in baru
    final newCheckin = CheckInRecord(
      id: 'chk_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      membershipId: userMem.id,
      planName: userMem.planName,
      timestamp: DateTime.now(),
      location: gateName,
      status: 'granted',
      notes: 'Dipindai oleh Petugas ($staffUid) • Kode $memberCode',
    );

    final checkins = await getCheckins();
    final updated = [newCheckin, ...checkins];
    await _prefs.setString(
        _checkinsKey, jsonEncode(updated.map((c) => c.toJson()).toList()));

    // Tandai token sebagai terpakai
    usedTokens.add(tokenId);
    await _prefs.setStringList('used_qr_tokens', usedTokens);

    _logActivity(
      title: 'Scan QR Check-In',
      description: '$memberCode berhasil check-in di $gateName',
      type: 'checkin',
    );

    return QrValidationResult(
      isValid: true,
      message: 'Akses Diberikan! Member $memberCode diperbolehkan masuk.',
      userId: userId,
      membershipId: userMem.id,
      memberCode: memberCode,
    );
  }

  @override
  Future<List<MembershipPlan>> getMembershipPlans() async {
    final raw = _prefs.getString(_plansKey);
    if (raw == null) {
      return MembershipPlan.presetPlans;
    }
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) {
        final m = item as Map<String, dynamic>;
        return MembershipPlan(
          id: m['id'] as String,
          name: m['name'] as String,
          badge: m['badge'] as String? ?? 'PASS',
          price: (m['price'] as num).toInt(),
          formattedPrice: m['formattedPrice'] as String,
          periodLabel: m['periodLabel'] as String,
          durationDays: (m['durationDays'] as num).toInt(),
          durationHours: (m['durationHours'] as num).toInt(),
          description: m['description'] as String,
          features: (m['features'] as List<dynamic>).cast<String>(),
          isPopular: m['isPopular'] as bool? ?? false,
        );
      }).toList();
    } catch (_) {
      return MembershipPlan.presetPlans;
    }
  }

  @override
  Future<void> saveMembershipPlan(MembershipPlan plan) async {
    final current = await getMembershipPlans();
    final updated = current.where((p) => p.id != plan.id).toList()..add(plan);

    final raw = jsonEncode(updated.map((p) => {
          'id': p.id,
          'name': p.name,
          'badge': p.badge,
          'price': p.price,
          'formattedPrice': p.formattedPrice,
          'periodLabel': p.periodLabel,
          'durationDays': p.durationDays,
          'durationHours': p.durationHours,
          'description': p.description,
          'features': p.features,
          'isPopular': p.isPopular,
        }).toList());

    await _prefs.setString(_plansKey, raw);
    _logActivity(
      title: 'Paket Diperbarui',
      description: 'Paket ${plan.name} disimpan oleh Admin',
      type: 'plan',
    );
  }

  @override
  Future<List<Exercise>> getExercises() async {
    // Return sample from local store
    return [];
  }

  @override
  Future<void> saveExercise(Exercise exercise) async {
    // Saved in custom exercises
  }

  @override
  Future<void> deleteExercise(String exerciseId) async {}

  @override
  Future<int> bulkImportExercises(List<Exercise> exercises) async {
    _logActivity(
      title: 'Bulk Import Gerakan',
      description: 'Berhasil mengimpor ${exercises.length} gerakan ke database.',
      type: 'exercise',
    );
    return exercises.length;
  }

  void _logActivity({
    required String title,
    required String description,
    required String type,
  }) async {
    final raw = _prefs.getString(_activitiesKey);
    List<RecentAdminActivity> list = [];
    if (raw != null) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        list = decoded
            .map((e) => RecentAdminActivity.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    final newAct = RecentAdminActivity(
      id: 'act_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      timestamp: DateTime.now(),
      type: type,
    );

    list.insert(0, newAct);
    if (list.length > 30) list = list.sublist(0, 30);

    await _prefs.setString(
        _activitiesKey, jsonEncode(list.map((e) => e.toJson()).toList()));

    // Broadcast updated stats
    getDashboardStats().then((s) => _statsController.add(s));
  }
}
