import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/weight_log_entry.dart';
import 'user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return UserProfile.fromMap(doc.data()!, uid);
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateWeightLog({
    required String uid,
    required double newWeightKg,
    String? note,
  }) async {
    final now = DateTime.now();
    // Simpan ke subkoleksi weightLogs
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('weightLogs')
        .add({
      'weightKg': newWeightKg,
      'loggedAt': now.toIso8601String(),
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Perbarui currentWeightKg di profil pengguna
    await _firestore.collection('users').doc(uid).update({
      'currentWeightKg': newWeightKg,
      'updatedAt': now.toIso8601String(),
    });
  }

  @override
  Stream<UserProfile?> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserProfile.fromMap(doc.data()!, uid);
    });
  }

  @override
  Stream<List<WeightLogEntry>> watchWeightLogs(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('weightLogs')
        .orderBy('loggedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WeightLogEntry.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<List<WeightLogEntry>> getWeightLogs(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('weightLogs')
        .orderBy('loggedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return WeightLogEntry.fromMap(doc.data(), doc.id);
    }).toList();
  }
}
