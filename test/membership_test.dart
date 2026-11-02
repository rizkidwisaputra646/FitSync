import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitsync/models/checkin_record.dart';
import 'package:fitsync/models/membership_plan.dart';
import 'package:fitsync/models/qr_checkin_token.dart';
import 'package:fitsync/models/user_membership.dart';
import 'package:fitsync/repositories/local_membership_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tahap 5: FitSync Membership Plans', () {
    test('Memastikan tersedianya dua paket utama: Member Harian & Member 1 Bulan', () {
      final plans = MembershipPlan.presetPlans;
      expect(plans.length, 2);

      final daily = plans.firstWhere((p) => p.id == 'daily-pass');
      expect(daily.name, 'Member Harian');
      expect(daily.price, 35000);
      expect(daily.durationDays, 1);
      expect(daily.durationHours, 24);

      final monthly = plans.firstWhere((p) => p.id == 'monthly-pass');
      expect(monthly.name, 'Member 1 Bulan');
      expect(monthly.price, 250000);
      expect(monthly.durationDays, 30);
      expect(monthly.isPopular, isTrue);
    });

    test('UserMembership menghitung status aktif dan sisa durasi dengan benar', () {
      final now = DateTime.now();
      
      // Membership aktif 30 hari
      final activeMembership = UserMembership(
        id: 'mem_1',
        userId: 'user_123',
        planId: 'monthly-pass',
        planName: 'Member 1 Bulan',
        startDate: now,
        expiryDate: now.add(const Duration(days: 30)),
        pricePaid: 250000,
        status: 'active',
        memberCode: 'FS-12345',
      );

      expect(activeMembership.isActive, isTrue);
      expect(activeMembership.remainingDays, inInclusiveRange(29, 30));
      expect(activeMembership.remainingLabel, contains('Hari Tersisa'));

      // Membership harian (24 jam)
      final dailyMembership = UserMembership(
        id: 'mem_2',
        userId: 'user_456',
        planId: 'daily-pass',
        planName: 'Member Harian',
        startDate: now,
        expiryDate: now.add(const Duration(hours: 24)),
        pricePaid: 35000,
        status: 'active',
      );

      expect(dailyMembership.isActive, isTrue);
      expect(dailyMembership.remainingHours, inInclusiveRange(23, 24));
      expect(dailyMembership.remainingLabel, contains('Jam Tersisa'));

      // Membership expired
      final expiredMembership = UserMembership(
        id: 'mem_3',
        userId: 'user_789',
        planId: 'daily-pass',
        planName: 'Member Harian',
        startDate: now.subtract(const Duration(days: 2)),
        expiryDate: now.subtract(const Duration(days: 1)),
        pricePaid: 35000,
        status: 'active',
      );

      expect(expiredMembership.isActive, isFalse);
      expect(expiredMembership.remainingLabel, 'Kedaluwarsa');
    });
  });

  group('Tahap 5: Dynamic 60-Second QR Check-In Token & Verification', () {
    test('Token QR berputar valid dalam 60 detik dengan HMAC-SHA256 signature', () {
      final token = QrCheckinToken.create(
        userId: 'user_test',
        membershipId: 'mem_test',
        memberCode: 'FS-99999',
      );

      expect(token.rawPayload.startsWith('FITSYNC:user_test:mem_test:FS-99999:'), isTrue);
      expect(token.isValid, isTrue);
      expect(token.secondsRemaining, inInclusiveRange(55, 60));

      // Verifikasi token valid via Turnstile Scanner
      final validation = QrCheckinToken.validate(token.rawPayload);
      expect(validation.isValid, isTrue);
      expect(validation.userId, 'user_test');
      expect(validation.memberCode, 'FS-99999');
      expect(validation.message, contains('Akses gym diberikan'));
    });

    test('Turnstile Scanner menolak QR yang sudah kedaluwarsa (> 65 detik)', () {
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expiredEpoch = nowEpoch - 90; // 90 detik yang lalu

      final expiredToken = QrCheckinToken.create(
        userId: 'user_test',
        membershipId: 'mem_test',
        memberCode: 'FS-99999',
        customEpoch: expiredEpoch,
      );

      final validation = QrCheckinToken.validate(expiredToken.rawPayload);
      expect(validation.isValid, isFalse);
      expect(validation.message, contains('telah kedaluwarsa'));
    });

    test('Turnstile Scanner menolak QR dengan signature palsu (tampered payload)', () {
      final token = QrCheckinToken.create(
        userId: 'user_test',
        membershipId: 'mem_test',
        memberCode: 'FS-99999',
      );

      // Ubah signature menjadi palsu
      final tamperedPayload = token.rawPayload.replaceAll(token.signature, 'fake_signature_x');
      final validation = QrCheckinToken.validate(tamperedPayload);

      expect(validation.isValid, isFalse);
      expect(validation.message, contains('Signature QR palsu'));
    });
  });

  group('Tahap 5: LocalMembershipRepository Offline-First Persistence', () {
    test('Aktivasi membership, retrieval, checkin history, dan reset berjalan mulus', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalMembershipRepository(prefs);

      // 1. Initial should be null
      final initial = await repo.getActiveMembership('user_offline');
      expect(initial, isNull);

      // 2. Activate Member 1 Bulan
      final now = DateTime.now();
      final membership = UserMembership(
        id: 'mem_off_1',
        userId: 'user_offline',
        planId: 'monthly-pass',
        planName: 'Member 1 Bulan',
        startDate: now,
        expiryDate: now.add(const Duration(days: 30)),
        pricePaid: 250000,
      );
      await repo.activateMembership(membership);

      final fetched = await repo.getActiveMembership('user_offline');
      expect(fetched, isNotNull);
      expect(fetched!.planName, 'Member 1 Bulan');
      expect(fetched.isActive, isTrue);

      // 3. Record Check-in
      final checkin = CheckInRecord(
        id: 'chk_1',
        userId: 'user_offline',
        membershipId: membership.id,
        planName: membership.planName,
        timestamp: DateTime.now(),
        location: 'Main Gate - Turnstile 01',
      );
      await repo.recordCheckIn(checkin);

      final history = await repo.getCheckInHistory('user_offline');
      expect(history.length, 1);
      expect(history.first.location, 'Main Gate - Turnstile 01');

      // 4. Cancel
      await repo.cancelMembership('user_offline');
      final afterCancel = await repo.getActiveMembership('user_offline');
      expect(afterCancel, isNull);
    });
  });
}
