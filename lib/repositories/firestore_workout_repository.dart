import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/workout/data/preset_workout_programs.dart';
import '../models/user_profile.dart';
import '../models/workout_program.dart';
import '../models/workout_session.dart';
import 'local_workout_repository.dart';
import 'workout_repository.dart';

class FirestoreWorkoutRepository implements WorkoutRepository {
  final FirebaseFirestore _firestore;
  final LocalWorkoutRepository _fallbackLocalRepo;

  FirestoreWorkoutRepository({
    required FirebaseFirestore firestore,
    required LocalWorkoutRepository fallbackLocalRepo,
  })  : _firestore = firestore,
        _fallbackLocalRepo = fallbackLocalRepo;

  CollectionReference<Map<String, dynamic>> _sessionsCol(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutSessions');
  }

  @override
  Future<WorkoutProgram> getProgramForProfile(UserProfile profile) async {
    // Program 30 hari dihasilkan secara deterministik sesuai algoritma profil
    return PresetWorkoutPrograms.getProgramForGoal(
      goal: profile.fitnessGoal,
      level: profile.experienceLevel,
    );
  }

  @override
  Future<List<WorkoutSession>> getWorkoutHistory(String userId) async {
    try {
      final snap = await _sessionsCol(userId)
          .orderBy('startTime', descending: true)
          .get();
      if (snap.docs.isEmpty) {
        return _fallbackLocalRepo.getWorkoutHistory(userId);
      }
      return snap.docs.map((doc) => WorkoutSession.fromMap(doc.data())).toList();
    } catch (_) {
      return _fallbackLocalRepo.getWorkoutHistory(userId);
    }
  }

  @override
  Stream<List<WorkoutSession>> watchWorkoutHistory(String userId) {
    try {
      return _sessionsCol(userId)
          .orderBy('startTime', descending: true)
          .snapshots()
          .map((snap) {
        return snap.docs
            .map((doc) => WorkoutSession.fromMap(doc.data()))
            .toList();
      });
    } catch (_) {
      return _fallbackLocalRepo.watchWorkoutHistory(userId);
    }
  }

  @override
  Future<void> saveWorkoutSession(WorkoutSession session) async {
    // Selalu simpan ke local fallback agar offline tersedia
    await _fallbackLocalRepo.saveWorkoutSession(session);

    try {
      await _sessionsCol(session.userId)
          .doc(session.sessionId)
          .set(session.toMap());
    } catch (_) {
      // Offline fallback telah tersimpan
    }
  }

  @override
  Future<int> getCompletedWorkoutsCount(String userId) async {
    try {
      final snap = await _sessionsCol(userId).count().get();
      return snap.count ?? 0;
    } catch (_) {
      return _fallbackLocalRepo.getCompletedWorkoutsCount(userId);
    }
  }

  @override
  Future<void> saveCustomizedDay(
      String userId, String programId, ProgramDay day) async {
    await _fallbackLocalRepo.saveCustomizedDay(userId, programId, day);
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('customizedPrograms')
          .doc(programId)
          .collection('days')
          .doc(day.dayNumber.toString())
          .set(day.toMap());
    } catch (_) {}
  }

  @override
  Future<Map<int, ProgramDay>> getCustomizedDays(
      String userId, String programId) async {
    return _fallbackLocalRepo.getCustomizedDays(userId, programId);
  }

  @override
  Future<void> resetDayToDefault(
      String userId, String programId, int dayNumber) async {
    await _fallbackLocalRepo.resetDayToDefault(userId, programId, dayNumber);
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('customizedPrograms')
          .doc(programId)
          .collection('days')
          .doc(dayNumber.toString())
          .delete();
    } catch (_) {}
  }
}
