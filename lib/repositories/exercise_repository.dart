import '../models/exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> getExercises({
    String? searchQuery,
    String? targetMuscle,
    String? equipment,
    String? difficulty,
    String? sortBy, // 'name_asc', 'name_desc', 'difficulty'
    int limit = 20,
    int offset = 0,
  });

  Future<Exercise?> getExerciseById(String id);
  Future<List<String>> getAllMuscleGroups();
  Future<List<String>> getAllEquipments();
  Future<void> saveCustomExercise(Exercise exercise);
  Future<void> deleteCustomExercise(String id);
}
