import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/checkin_record.dart';
import '../models/user_membership.dart';
import 'local_membership_repository.dart';
import 'membership_repository.dart';

class FirestoreMembershipRepository implements MembershipRepository {
  final FirebaseFirestore _firestore;
  final LocalMembershipRepository _fallbackRepo;

  FirestoreMembershipRepository(this._firestore, this._fallbackRepo);

  @override
  Future<UserMembership?> getActiveMembership(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('membership')
          .doc('active')
          .get();

      if (doc.exists && doc.data() != null) {
        final membership = UserMembership.fromJson(doc.data()!);
        // Sinkronkan ke local fallback
        await _fallbackRepo.activateMembership(membership);
        return membership;
      }
      return await _fallbackRepo.getActiveMembership(userId);
    } catch (_) {
      return await _fallbackRepo.getActiveMembership(userId);
    }
  }

  @override
  Stream<UserMembership?> watchActiveMembership(String userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('membership')
          .doc('active')
          .snapshots()
          .map((doc) {
        if (doc.exists && doc.data() != null) {
          final m = UserMembership.fromJson(doc.data()!);
          _fallbackRepo.activateMembership(m);
          return m;
        }
        return null;
      }).handleError((_) => _fallbackRepo.watchActiveMembership(userId));
    } catch (_) {
      return _fallbackRepo.watchActiveMembership(userId);
    }
  }

  @override
  Future<void> activateMembership(UserMembership membership) async {
    await _fallbackRepo.activateMembership(membership);
    try {
      await _firestore
          .collection('users')
          .doc(membership.userId)
          .collection('membership')
          .doc('active')
          .set(membership.toJson(), SetOptions(merge: true));
    } catch (_) {
      // Fallback local saved
    }
  }

  @override
  Future<void> cancelMembership(String userId) async {
    await _fallbackRepo.cancelMembership(userId);
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('membership')
          .doc('active')
          .delete();
    } catch (_) {
      // Fallback local deleted
    }
  }

  @override
  Future<List<CheckInRecord>> getCheckInHistory(String userId) async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkin_history')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((d) => CheckInRecord.fromJson(d.data()))
            .toList();
      }
      return await _fallbackRepo.getCheckInHistory(userId);
    } catch (_) {
      return await _fallbackRepo.getCheckInHistory(userId);
    }
  }

  @override
  Future<CheckInRecord> recordCheckIn(CheckInRecord record) async {
    await _fallbackRepo.recordCheckIn(record);
    try {
      await _firestore
          .collection('users')
          .doc(record.userId)
          .collection('checkin_history')
          .doc(record.id)
          .set(record.toJson());
    } catch (_) {
      // Saved to local
    }
    return record;
  }
}
