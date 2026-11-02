import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise.dart';
import 'exercise_repository.dart';
import 'local_asset_exercise_repository.dart';

class FirestoreExerciseRepository implements ExerciseRepository {
  final FirebaseFirestore _firestore;
  final LocalAssetExerciseRepository _fallbackRepo =
      LocalAssetExerciseRepository();

  FirestoreExerciseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Exercise>> getExercises({
    String? searchQuery,
    String? targetMuscle,
    String? equipment,
    String? difficulty,
    String? sortBy,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('exercises')
          .where('isActive', isEqualTo: true);

      if (targetMuscle != null &&
          targetMuscle.isNotEmpty &&
          targetMuscle != 'Semua') {
        query = query.where('targetMuscle', isEqualTo: targetMuscle);
      }

      if (equipment != null && equipment.isNotEmpty && equipment != 'Semua') {
        query = query.where('equipment', isEqualTo: equipment);
      }

      if (difficulty != null &&
          difficulty.isNotEmpty &&
          difficulty != 'Semua') {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final snapshot = await query.limit(limit).get();
      if (snapshot.docs.isEmpty) {
        // Fallback jika belum di-import ke cloud
        return _fallbackRepo.getExercises(
          searchQuery: searchQuery,
          targetMuscle: targetMuscle,
          equipment: equipment,
          difficulty: difficulty,
          sortBy: sortBy,
          limit: limit,
          offset: offset,
        );
      }

      final list = snapshot.docs
          .map((doc) => Exercise.fromMap(doc.data(), doc.id))
          .toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return list
            .where((e) =>
                e.name.toLowerCase().contains(q) ||
                e.targetMuscle.toLowerCase().contains(q))
            .toList();
      }

      return list;
    } catch (_) {
      // Fallback ke dataset lokal bila jaringan / koneksi bermasalah
      return _fallbackRepo.getExercises(
        searchQuery: searchQuery,
        targetMuscle: targetMuscle,
        equipment: equipment,
        difficulty: difficulty,
        sortBy: sortBy,
        limit: limit,
        offset: offset,
      );
    }
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    try {
      final doc = await _firestore.collection('exercises').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Exercise.fromMap(doc.data()!, doc.id);
      }
      return _fallbackRepo.getExerciseById(id);
    } catch (_) {
      return _fallbackRepo.getExerciseById(id);
    }
  }

  @override
  Future<List<String>> getAllMuscleGroups() {
    return _fallbackRepo.getAllMuscleGroups();
  }

  @override
  Future<List<String>> getAllEquipments() {
    return _fallbackRepo.getAllEquipments();
  }

  @override
  Future<void> saveCustomExercise(Exercise exercise) async {
    await _fallbackRepo.saveCustomExercise(exercise);
    try {
      await _firestore
          .collection('exercises')
          .doc(exercise.id)
          .set(exercise.toMap());
    } catch (_) {}
  }

  @override
  Future<void> deleteCustomExercise(String id) async {
    await _fallbackRepo.deleteCustomExercise(id);
    try {
      await _firestore.collection('exercises').doc(id).delete();
    } catch (_) {}
  }
}
