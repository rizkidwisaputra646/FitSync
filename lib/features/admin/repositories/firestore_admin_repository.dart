import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/checkin_record.dart';
import '../../../models/exercise.dart';
import '../../../models/membership_plan.dart';
import '../../../models/qr_checkin_token.dart';
import '../models/admin_stats.dart';
import '../models/payment_transaction.dart';
import 'admin_repository.dart';
import 'local_admin_repository.dart';

class FirestoreAdminRepository implements AdminRepository {
  final FirebaseFirestore _firestore;
  final LocalAdminRepository _fallbackRepo;

  FirestoreAdminRepository(this._firestore, this._fallbackRepo);

  @override
  Future<AdminStats> getDashboardStats() async {
    try {
      final membersSnap = await _firestore.collection('users').get();
      final totalMembers = membersSnap.docs.length;

      final paymentsSnap = await _firestore
          .collection('payments')
          .where('status', isEqualTo: 'pending')
          .get();
      final pendingCount = paymentsSnap.docs.length;

      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final checkinsSnap = await _firestore
          .collectionGroup('checkin_history')
          .where('timestamp',
              isGreaterThanOrEqualTo: startOfToday.toIso8601String())
          .get();
      final todayCheckins = checkinsSnap.docs.length;

      final localStats = await _fallbackRepo.getDashboardStats();

      return AdminStats(
        totalMembers: totalMembers > 0 ? totalMembers : localStats.totalMembers,
        activeMembers: localStats.activeMembers,
        expiredMembers: localStats.expiredMembers,
        pendingPayments: pendingCount,
        todayCheckins: todayCheckins > 0 ? todayCheckins : localStats.todayCheckins,
        weeklyCheckins: localStats.weeklyCheckins,
        recentActivities: localStats.recentActivities,
      );
    } catch (_) {
      return await _fallbackRepo.getDashboardStats();
    }
  }

  @override
  Stream<AdminStats> watchDashboardStats() async* {
    yield await getDashboardStats();
    yield* _fallbackRepo.watchDashboardStats();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllMembers() async {
    try {
      final snap = await _firestore.collection('users').get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) {
          final data = d.data();
          data['uid'] = d.id;
          return data;
        }).toList();
      }
      return await _fallbackRepo.getAllMembers();
    } catch (_) {
      return await _fallbackRepo.getAllMembers();
    }
  }

  @override
  Future<void> updateMemberStatus(
    String userId,
    String status, {
    DateTime? customExpiry,
    String? adminNotes,
  }) async {
    await _fallbackRepo.updateMemberStatus(
      userId,
      status,
      customExpiry: customExpiry,
      adminNotes: adminNotes,
    );

    try {
      final updates = <String, dynamic>{
        'membershipStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (customExpiry != null) {
        updates['membershipExpiry'] = customExpiry.toIso8601String();
      }
      if (adminNotes != null) {
        updates['adminNotes'] = adminNotes;
      }
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (_) {}
  }

  @override
  Future<List<PaymentTransaction>> getAllPayments(
      {String? statusFilter}) async {
    try {
      Query query =
          _firestore.collection('payments').orderBy('createdAt', descending: true);
      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter);
      }
      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((d) =>
                PaymentTransaction.fromJson(d.data() as Map<String, dynamic>))
            .toList();
      }
      return await _fallbackRepo.getAllPayments(statusFilter: statusFilter);
    } catch (_) {
      return await _fallbackRepo.getAllPayments(statusFilter: statusFilter);
    }
  }

  @override
  Future<void> createPaymentRequest(PaymentTransaction transaction) async {
    await _fallbackRepo.createPaymentRequest(transaction);
    try {
      await _firestore
          .collection('payments')
          .doc(transaction.id)
          .set(transaction.toJson());
    } catch (_) {}
  }

  @override
  Future<void> approvePayment(String paymentId, String adminUid) async {
    await _fallbackRepo.approvePayment(paymentId, adminUid);
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'approved',
        'processedByAdminId': adminUid,
        'processedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Future<void> rejectPayment(
      String paymentId, String adminUid, String reason) async {
    await _fallbackRepo.rejectPayment(paymentId, adminUid, reason);
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'processedByAdminId': adminUid,
        'processedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Future<List<CheckInRecord>> getCheckins({DateTime? date}) async {
    try {
      final snap = await _firestore
          .collectionGroup('checkin_history')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((d) => CheckInRecord.fromJson(d.data()))
            .toList();
      }
      return await _fallbackRepo.getCheckins(date: date);
    } catch (_) {
      return await _fallbackRepo.getCheckins(date: date);
    }
  }

  @override
  Future<QrValidationResult> verifyAndProcessQrCheckin({
    required String qrPayload,
    required String gateName,
    required String staffUid,
  }) async {
    final result = await _fallbackRepo.verifyAndProcessQrCheckin(
      qrPayload: qrPayload,
      gateName: gateName,
      staffUid: staffUid,
    );

    if (result.isValid && result.userId != null) {
      try {
        final checkinId = 'chk_${DateTime.now().millisecondsSinceEpoch}';
        await _firestore
            .collection('users')
            .doc(result.userId)
            .collection('checkin_history')
            .doc(checkinId)
            .set({
          'id': checkinId,
          'userId': result.userId,
          'membershipId': result.membershipId ?? '',
          'planName': 'Member Pass',
          'timestamp': DateTime.now().toIso8601String(),
          'location': gateName,
          'status': 'granted',
          'notes': 'Verified by Staff $staffUid',
        });
      } catch (_) {}
    }

    return result;
  }

  @override
  Future<List<MembershipPlan>> getMembershipPlans() async {
    try {
      final snap = await _firestore.collection('membership_plans').get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) {
          final m = d.data();
          return MembershipPlan(
            id: d.id,
            name: m['name'] as String? ?? 'Pass',
            badge: m['badge'] as String? ?? 'PASS',
            price: (m['price'] as num?)?.toInt() ?? 0,
            formattedPrice: m['formattedPrice'] as String? ?? 'Rp 0',
            periodLabel: m['periodLabel'] as String? ?? '/ Bulan',
            durationDays: (m['durationDays'] as num?)?.toInt() ?? 30,
            durationHours: (m['durationHours'] as num?)?.toInt() ?? 720,
            description: m['description'] as String? ?? '',
            features: (m['features'] as List<dynamic>?)?.cast<String>() ?? [],
            isPopular: m['isPopular'] as bool? ?? false,
          );
        }).toList();
      }
      return await _fallbackRepo.getMembershipPlans();
    } catch (_) {
      return await _fallbackRepo.getMembershipPlans();
    }
  }

  @override
  Future<void> saveMembershipPlan(MembershipPlan plan) async {
    await _fallbackRepo.saveMembershipPlan(plan);
    try {
      await _firestore.collection('membership_plans').doc(plan.id).set({
        'name': plan.name,
        'badge': plan.badge,
        'price': plan.price,
        'formattedPrice': plan.formattedPrice,
        'periodLabel': plan.periodLabel,
        'durationDays': plan.durationDays,
        'durationHours': plan.durationHours,
        'description': plan.description,
        'features': plan.features,
        'isPopular': plan.isPopular,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<List<Exercise>> getExercises() => _fallbackRepo.getExercises();

  @override
  Future<void> saveExercise(Exercise exercise) async {
    try {
      await _firestore
          .collection('exercises')
          .doc(exercise.id)
          .set(exercise.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _firestore.collection('exercises').doc(exerciseId).delete();
    } catch (_) {}
  }

  @override
  Future<int> bulkImportExercises(List<Exercise> exercises) async {
    int count = 0;
    try {
      final batch = _firestore.batch();
      for (final ex in exercises) {
        final ref = _firestore.collection('exercises').doc(ex.id);
        batch.set(ref, ex.toMap(), SetOptions(merge: true));
        count++;
        if (count >= 400) break; // Firestore batch limit is 500 ops
      }
      await batch.commit();
    } catch (_) {}
    await _fallbackRepo.bulkImportExercises(exercises);
    return count > 0 ? count : exercises.length;
  }
}
