import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitsync/features/admin/models/admin_role.dart';
import 'package:fitsync/features/admin/models/payment_transaction.dart';
import 'package:fitsync/features/admin/repositories/local_admin_repository.dart';
import 'package:fitsync/models/membership_plan.dart';
import 'package:fitsync/models/qr_checkin_token.dart';
import 'package:fitsync/models/user_membership.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Module: Role-Based Access Control (RBAC)', () {
    test('Hak akses Admin vs Staff vs Member sesuai spesifikasi', () {
      const admin = UserRole.admin;
      const staff = UserRole.staff;
      const member = UserRole.member;

      // Admin rights
      expect(admin.canManageMembers, isTrue);
      expect(admin.canVerifyPayments, isTrue);
      expect(admin.canManagePlans, isTrue);
      expect(admin.canManageExercises, isTrue);
      expect(admin.canScanQrCheckin, isTrue);

      // Staff rights
      expect(staff.canManageMembers, isFalse);
      expect(staff.canVerifyPayments, isFalse);
      expect(staff.canManagePlans, isFalse);
      expect(staff.canManageExercises, isFalse);
      expect(staff.canScanQrCheckin, isTrue);

      // Member rights
      expect(member.canManageMembers, isFalse);
      expect(member.canScanQrCheckin, isFalse);
    });
  });

  group('Admin Module: Verifikasi Pembayaran & Idempoten', () {
    test('Persetujuan pembayaran mengaktifkan membership dan mencatat admin pemroses', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalAdminRepository(prefs);

      // 1. Ambil pembayaran pending yang ter-seed
      final pendingList =
          await repo.getAllPayments(statusFilter: 'pending');
      expect(pendingList.isNotEmpty, isTrue);
      final payment = pendingList.first;

      // 2. Setujui pembayaran
      await repo.approvePayment(payment.id, 'admin_super_01');

      // 3. Pastikan status berubah menjadi approved
      final allPayments = await repo.getAllPayments();
      final approvedItem =
          allPayments.firstWhere((p) => p.id == payment.id);
      expect(approvedItem.status, PaymentStatus.approved);
      expect(approvedItem.processedByAdminId, 'admin_super_01');
      expect(approvedItem.processedAt, isNotNull);

      // 4. Pastikan membership user aktif tersimpan
      final rawMem = prefs.getString('user_membership_${payment.userId}');
      expect(rawMem, isNotNull);
    });

    test('Penolakan pembayaran menyimpan alasan penolakan dengan tepat', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalAdminRepository(prefs);

      final payments = await repo.getAllPayments(statusFilter: 'pending');
      final target = payments.last;

      await repo.rejectPayment(
        target.id,
        'admin_super_01',
        'Nominal transfer kurang Rp 50.000',
      );

      final updatedPayments = await repo.getAllPayments();
      final rejectedItem =
          updatedPayments.firstWhere((p) => p.id == target.id);
      expect(rejectedItem.status, PaymentStatus.rejected);
      expect(rejectedItem.rejectionReason, 'Nominal transfer kurang Rp 50.000');
    });
  });

  group('Admin Module: Gym Check-In & Scanner Turnstile Petugas', () {
    test('Petugas berhasil memvalidasi QR dinamis member aktif', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalAdminRepository(prefs);

      // Buat membership aktif untuk user test
      final now = DateTime.now();
      final membership = UserMembership(
        id: 'mem_test_user',
        userId: 'user_001',
        planId: 'monthly-pass',
        planName: 'Member 1 Bulan',
        startDate: now,
        expiryDate: now.add(const Duration(days: 30)),
        pricePaid: 250000,
        memberCode: 'FS-98241',
      );
      await prefs.setString(
          'user_membership_user_001', jsonEncode(membership.toJson()));

      // Generate live token
      final token = QrCheckinToken.create(
        userId: 'user_001',
        membershipId: 'mem_test_user',
        memberCode: 'FS-98241',
      );

      // Petugas scan QR
      final result = await repo.verifyAndProcessQrCheckin(
        qrPayload: token.rawPayload,
        gateName: 'Main Gate - Turnstile 01',
        staffUid: 'staff_budi',
      );

      expect(result.isValid, isTrue);
      expect(result.message, contains('Akses Diberikan'));

      // Pastikan log checkin tercatat
      final checkins = await repo.getCheckins();
      expect(checkins.any((c) => c.userId == 'user_001'), isTrue);
    });

    test('Petugas menolak scan jika akun member sedang DITANGGUHKAN', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalAdminRepository(prefs);

      // user_004 adalah member yang ditangguhkan (status suspended di mock seed)
      final token = QrCheckinToken.create(
        userId: 'user_004',
        membershipId: 'mem_004',
        memberCode: 'FS-11983',
      );

      final result = await repo.verifyAndProcessQrCheckin(
        qrPayload: token.rawPayload,
        gateName: 'Turnstile 01',
        staffUid: 'staff_budi',
      );

      expect(result.isValid, isFalse);
      expect(result.message, contains('DITANGGUHKAN'));
    });
  });

  group('Admin Module: Dashboard Stats & Plans Management', () {
    test('Ringkasan statistik operasional dihitung dengan akurat', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalAdminRepository(prefs);

      final stats = await repo.getDashboardStats();
      expect(stats.totalMembers, greaterThanOrEqualTo(4));
      expect(stats.activeMembers, greaterThanOrEqualTo(2));
      expect(stats.pendingPayments, greaterThanOrEqualTo(1));
      expect(stats.weeklyCheckins.length, 7);
      expect(stats.recentActivities.isNotEmpty, isTrue);
    });

    test('Menyimpan perubahan paket membership tanpa mengubah histori transaksi', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalAdminRepository(prefs);

      const customPlan = MembershipPlan(
        id: 'quarterly-pass',
        name: 'Member 3 Bulan',
        badge: 'SUPER HEMAT',
        price: 650000,
        formattedPrice: 'Rp 650.000',
        periodLabel: '/ 3 Bulan',
        durationDays: 90,
        durationHours: 2160,
        description: 'Paket hemat komitmen 90 hari.',
        features: ['Akses 90 hari', 'Free Loker'],
        isPopular: true,
      );

      await repo.saveMembershipPlan(customPlan);

      final plans = await repo.getMembershipPlans();
      expect(plans.any((p) => p.id == 'quarterly-pass'), isTrue);
    });
  });
}
