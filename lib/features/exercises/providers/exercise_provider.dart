import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/exercise.dart';
import '../../../repositories/exercise_repository.dart';
import '../../../repositories/firestore_exercise_repository.dart';
import '../../../repositories/local_asset_exercise_repository.dart';
import '../../../services/firebase_service.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  if (FirebaseService.isInitialized) {
    return FirestoreExerciseRepository();
  }
  return LocalAssetExerciseRepository();
});

class ExerciseFilterState {
  final String searchQuery;
  final String selectedMuscle;
  final String selectedEquipment;
  final String selectedDifficulty;
  final String sortBy; // 'name_asc', 'name_desc'

  const ExerciseFilterState({
    this.searchQuery = '',
    this.selectedMuscle = 'Semua',
    this.selectedEquipment = 'Semua',
    this.selectedDifficulty = 'Semua',
    this.sortBy = 'name_asc',
  });

  ExerciseFilterState copyWith({
    String? searchQuery,
    String? selectedMuscle,
    String? selectedEquipment,
    String? selectedDifficulty,
    String? sortBy,
  }) {
    return ExerciseFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMuscle: selectedMuscle ?? this.selectedMuscle,
      selectedEquipment: selectedEquipment ?? this.selectedEquipment,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class ExerciseFilterNotifier extends StateNotifier<ExerciseFilterState> {
  ExerciseFilterNotifier() : super(const ExerciseFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setMuscle(String muscle) {
    state = state.copyWith(selectedMuscle: muscle);
  }

  void setEquipment(String equip) {
    state = state.copyWith(selectedEquipment: equip);
  }

  void setDifficulty(String diff) {
    state = state.copyWith(selectedDifficulty: diff);
  }

  void setSortBy(String sort) {
    state = state.copyWith(sortBy: sort);
  }

  void resetFilters() {
    state = const ExerciseFilterState();
  }
}

final exerciseFilterProvider =
    StateNotifierProvider<ExerciseFilterNotifier, ExerciseFilterState>((ref) {
  return ExerciseFilterNotifier();
});

final muscleGroupsProvider = FutureProvider<List<String>>((ref) {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getAllMuscleGroups();
});

final equipmentsProvider = FutureProvider<List<String>>((ref) {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getAllEquipments();
});

final exerciseListProvider = FutureProvider<List<Exercise>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  final filter = ref.watch(exerciseFilterProvider);

  return repo.getExercises(
    searchQuery: filter.searchQuery,
    targetMuscle: filter.selectedMuscle,
    equipment: filter.selectedEquipment,
    difficulty: filter.selectedDifficulty,
    sortBy: filter.sortBy,
    limit: 60, // Ambil 60 item pertama per filter, tidak 300 sekaligus
    offset: 0,
  );
});

final exerciseDetailProvider =
    FutureProvider.family<Exercise?, String>((ref, id) {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getExerciseById(id);
});
