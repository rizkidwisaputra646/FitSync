import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_profile.dart';
import '../../../models/workout_program.dart';
import '../../../models/workout_session.dart';
import '../../../repositories/firestore_workout_repository.dart';
import '../../../repositories/local_workout_repository.dart';
import '../../../repositories/workout_repository.dart';
import '../../../services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';

// 1. Repository Provider
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final localRepo = LocalWorkoutRepository(prefs);

  if (FirebaseService.isInitialized) {
    try {
      return FirestoreWorkoutRepository(
        firestore: FirebaseFirestore.instance,
        fallbackLocalRepo: localRepo,
      );
    } catch (_) {
      return localRepo;
    }
  }
  return localRepo;
});

// 2. Adapted 30-Day Workout Program Provider
final workoutProgramProvider = FutureProvider<WorkoutProgram?>((ref) async {
  final profile = await ref.watch(currentUserProfileProvider.future);
  if (profile == null) return null;

  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getProgramForProfile(profile);
});

// 3. Workout History Stream Provider
final workoutHistoryProvider =
    StreamProvider.autoDispose<List<WorkoutSession>>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  final repo = ref.watch(workoutRepositoryProvider);

  return profileAsync.when(
    data: (profile) {
      if (profile == null) return Stream.value([]);
      return repo.watchWorkoutHistory(profile.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// 4. Completed Workouts Set / Map for Day Checking (e.g. Day 1 completed, Day 2 completed)
final completedDaysProvider = Provider<Set<int>>((ref) {
  final historyAsync = ref.watch(workoutHistoryProvider);
  return historyAsync.maybeWhen(
    data: (sessions) => sessions.map((s) => s.dayNumber).toSet(),
    orElse: () => <int>{},
  );
});

// 5. Active Workout Session State
class ActiveWorkoutState {
  final WorkoutSession? session;
  final int currentExerciseIndex;
  final int elapsedSeconds;
  final int restSecondsRemaining;
  final bool isResting;
  final bool isSaving;

  const ActiveWorkoutState({
    this.session,
    this.currentExerciseIndex = 0,
    this.elapsedSeconds = 0,
    this.restSecondsRemaining = 0,
    this.isResting = false,
    this.isSaving = false,
  });

  bool get isActive => session != null;

  String get formattedElapsedTime {
    final m = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  SessionExerciseRecord? get currentExercise {
    if (session == null ||
        currentExerciseIndex < 0 ||
        currentExerciseIndex >= session!.exercises.length) {
      return null;
    }
    return session!.exercises[currentExerciseIndex];
  }

  ActiveWorkoutState copyWith({
    WorkoutSession? session,
    int? currentExerciseIndex,
    int? elapsedSeconds,
    int? restSecondsRemaining,
    bool? isResting,
    bool? isSaving,
  }) {
    return ActiveWorkoutState(
      session: session ?? this.session,
      currentExerciseIndex:
          currentExerciseIndex ?? this.currentExerciseIndex,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      restSecondsRemaining:
          restSecondsRemaining ?? this.restSecondsRemaining,
      isResting: isResting ?? this.isResting,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

// 6. Active Workout Controller
class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _restTimer;

  ActiveWorkoutNotifier(this._ref) : super(const ActiveWorkoutState());

  void startSession({
    required UserProfile profile,
    required WorkoutProgram program,
    required ProgramDay day,
  }) {
    _sessionTimer?.cancel();
    _restTimer?.cancel();

    final exercises = day.exercises.map((pEx) {
      // Buat target sets
      final loggedSets = List.generate(
        pEx.targetSets,
        (i) => LoggedSet(
          setNumber: i + 1,
          targetReps: int.tryParse(pEx.targetReps.split('-').first) ?? 10,
          actualReps: int.tryParse(pEx.targetReps.split('-').first) ?? 10,
          actualWeightKg: 0.0,
          isCompleted: false,
        ),
      );

      return SessionExerciseRecord(
        exerciseId: pEx.exerciseId,
        exerciseName: pEx.exerciseName,
        targetMuscle: pEx.targetMuscle,
        sets: loggedSets,
      );
    }).toList();

    final initialSession = WorkoutSession(
      sessionId: 'ws_${DateTime.now().millisecondsSinceEpoch}',
      userId: profile.uid,
      programId: program.id,
      programTitle: program.title,
      dayNumber: day.dayNumber,
      dayTitle: day.title,
      startTime: DateTime.now(),
      durationSeconds: 0,
      totalVolumeKg: 0.0,
      totalSetsCompleted: 0,
      caloriesBurned: 0,
      exercises: exercises,
    );

    state = ActiveWorkoutState(
      session: initialSession,
      currentExerciseIndex: 0,
      elapsedSeconds: 0,
      restSecondsRemaining: 0,
      isResting: false,
    );

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void selectExercise(int index) {
    if (state.session == null) return;
    if (index >= 0 && index < state.session!.exercises.length) {
      state = state.copyWith(currentExerciseIndex: index);
    }
  }

  void nextExercise() {
    if (state.session == null) return;
    if (state.currentExerciseIndex < state.session!.exercises.length - 1) {
      state = state.copyWith(
          currentExerciseIndex: state.currentExerciseIndex + 1);
    }
  }

  void prevExercise() {
    if (state.session == null) return;
    if (state.currentExerciseIndex > 0) {
      state = state.copyWith(
          currentExerciseIndex: state.currentExerciseIndex - 1);
    }
  }

  void addExercise(
    String exerciseId,
    String exerciseName,
    String targetMuscle, {
    int setsCount = 3,
    int targetReps = 10,
  }) {
    if (state.session == null) return;
    final exercises = [...state.session!.exercises];

    final newSets = List.generate(
      setsCount,
      (i) => LoggedSet(
        setNumber: i + 1,
        targetReps: targetReps,
        actualReps: targetReps,
        actualWeightKg: 0.0,
        isCompleted: false,
      ),
    );

    exercises.add(
      SessionExerciseRecord(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        targetMuscle: targetMuscle,
        sets: newSets,
      ),
    );

    state = state.copyWith(
      session: WorkoutSession(
        sessionId: state.session!.sessionId,
        userId: state.session!.userId,
        programId: state.session!.programId,
        programTitle: state.session!.programTitle,
        dayNumber: state.session!.dayNumber,
        dayTitle: state.session!.dayTitle,
        startTime: state.session!.startTime,
        durationSeconds: state.elapsedSeconds,
        totalVolumeKg: state.session!.totalVolumeKg,
        totalSetsCompleted: state.session!.totalSetsCompleted,
        caloriesBurned: state.session!.caloriesBurned,
        exercises: exercises,
      ),
      currentExerciseIndex: exercises.length - 1,
    );
  }

  void removeExercise(int index) {
    if (state.session == null || state.session!.exercises.length <= 1) return;
    final exercises = [...state.session!.exercises];
    if (index >= 0 && index < exercises.length) {
      exercises.removeAt(index);
      final newIndex = state.currentExerciseIndex >= exercises.length
          ? exercises.length - 1
          : state.currentExerciseIndex;

      state = state.copyWith(
        session: WorkoutSession(
          sessionId: state.session!.sessionId,
          userId: state.session!.userId,
          programId: state.session!.programId,
          programTitle: state.session!.programTitle,
          dayNumber: state.session!.dayNumber,
          dayTitle: state.session!.dayTitle,
          startTime: state.session!.startTime,
          durationSeconds: state.elapsedSeconds,
          totalVolumeKg: state.session!.totalVolumeKg,
          totalSetsCompleted: state.session!.totalSetsCompleted,
          caloriesBurned: state.session!.caloriesBurned,
          exercises: exercises,
        ),
        currentExerciseIndex: newIndex,
      );
    }
  }

  void addSetToExercise(int exerciseIdx) {
    if (state.session == null) return;
    final exercises = [...state.session!.exercises];
    final ex = exercises[exerciseIdx];
    final sets = [...ex.sets];

    final lastSet = sets.isNotEmpty ? sets.last : null;
    final newSet = LoggedSet(
      setNumber: sets.length + 1,
      targetReps: lastSet?.targetReps ?? 10,
      actualReps: lastSet?.actualReps ?? 10,
      actualWeightKg: lastSet?.actualWeightKg ?? 0.0,
      isCompleted: false,
    );
    sets.add(newSet);

    exercises[exerciseIdx] = SessionExerciseRecord(
      exerciseId: ex.exerciseId,
      exerciseName: ex.exerciseName,
      targetMuscle: ex.targetMuscle,
      sets: sets,
    );

    state = state.copyWith(
      session: WorkoutSession(
        sessionId: state.session!.sessionId,
        userId: state.session!.userId,
        programId: state.session!.programId,
        programTitle: state.session!.programTitle,
        dayNumber: state.session!.dayNumber,
        dayTitle: state.session!.dayTitle,
        startTime: state.session!.startTime,
        durationSeconds: state.elapsedSeconds,
        totalVolumeKg: state.session!.totalVolumeKg,
        totalSetsCompleted: state.session!.totalSetsCompleted,
        caloriesBurned: state.session!.caloriesBurned,
        exercises: exercises,
      ),
    );
  }

  void updateSetActuals(
    int exerciseIdx,
    int setIdx, {
    double? weightKg,
    int? reps,
  }) {
    if (state.session == null) return;
    final exercises = [...state.session!.exercises];
    final currentEx = exercises[exerciseIdx];
    final sets = [...currentEx.sets];
    final set = sets[setIdx];

    sets[setIdx] = set.copyWith(
      actualWeightKg: weightKg ?? set.actualWeightKg,
      actualReps: reps ?? set.actualReps,
    );

    exercises[exerciseIdx] = SessionExerciseRecord(
      exerciseId: currentEx.exerciseId,
      exerciseName: currentEx.exerciseName,
      targetMuscle: currentEx.targetMuscle,
      sets: sets,
    );

    state = state.copyWith(
      session: WorkoutSession(
        sessionId: state.session!.sessionId,
        userId: state.session!.userId,
        programId: state.session!.programId,
        programTitle: state.session!.programTitle,
        dayNumber: state.session!.dayNumber,
        dayTitle: state.session!.dayTitle,
        startTime: state.session!.startTime,
        durationSeconds: state.elapsedSeconds,
        totalVolumeKg: state.session!.totalVolumeKg,
        totalSetsCompleted: state.session!.totalSetsCompleted,
        caloriesBurned: state.session!.caloriesBurned,
        exercises: exercises,
      ),
    );
  }

  void toggleSetCompleted(int exerciseIdx, int setIdx, {int restSeconds = 60}) {
    if (state.session == null) return;
    final exercises = [...state.session!.exercises];
    final currentEx = exercises[exerciseIdx];
    final sets = [...currentEx.sets];
    final set = sets[setIdx];

    final newStatus = !set.isCompleted;
    sets[setIdx] = set.copyWith(isCompleted: newStatus);

    exercises[exerciseIdx] = SessionExerciseRecord(
      exerciseId: currentEx.exerciseId,
      exerciseName: currentEx.exerciseName,
      targetMuscle: currentEx.targetMuscle,
      sets: sets,
    );

    state = state.copyWith(
      session: WorkoutSession(
        sessionId: state.session!.sessionId,
        userId: state.session!.userId,
        programId: state.session!.programId,
        programTitle: state.session!.programTitle,
        dayNumber: state.session!.dayNumber,
        dayTitle: state.session!.dayTitle,
        startTime: state.session!.startTime,
        durationSeconds: state.elapsedSeconds,
        totalVolumeKg: state.session!.totalVolumeKg,
        totalSetsCompleted: state.session!.totalSetsCompleted,
        caloriesBurned: state.session!.caloriesBurned,
        exercises: exercises,
      ),
    );

    // Jika baru saja menyelesaikan set, picu otomatis rest timer
    if (newStatus) {
      startRestTimer(restSeconds);
    }
  }

  void startRestTimer(int seconds) {
    _restTimer?.cancel();
    state = state.copyWith(
      restSecondsRemaining: seconds,
      isResting: true,
    );

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.restSecondsRemaining <= 1) {
        timer.cancel();
        state = state.copyWith(
          restSecondsRemaining: 0,
          isResting: false,
        );
      } else {
        state = state.copyWith(
          restSecondsRemaining: state.restSecondsRemaining - 1,
        );
      }
    });
  }

  void addRestSeconds(int seconds) {
    if (state.isResting) {
      state = state.copyWith(
        restSecondsRemaining: state.restSecondsRemaining + seconds,
      );
    } else {
      startRestTimer(seconds);
    }
  }

  void skipRestTimer() {
    _restTimer?.cancel();
    state = state.copyWith(
      restSecondsRemaining: 0,
      isResting: false,
    );
  }

  Future<WorkoutSession?> finishSession({
    required double userWeightKg,
  }) async {
    if (state.session == null) return null;

    state = state.copyWith(isSaving: true);
    _sessionTimer?.cancel();
    _restTimer?.cancel();

    // Hitung total metrik
    double totalVolume = 0.0;
    int completedSets = 0;

    for (final ex in state.session!.exercises) {
      for (final s in ex.sets) {
        if (s.isCompleted) {
          completedSets++;
          totalVolume += (s.actualWeightKg * s.actualReps);
        }
      }
    }

    // Estimasi kalori terbakar: MET ~ 5.5 untuk latihan beban intensitas sedang/tinggi
    // Kalori = MET * berat (kg) * jam
    final hours = state.elapsedSeconds / 3600.0;
    final calories = (5.5 * userWeightKg * hours).round().clamp(10, 1500);

    final finalSession = WorkoutSession(
      sessionId: state.session!.sessionId,
      userId: state.session!.userId,
      programId: state.session!.programId,
      programTitle: state.session!.programTitle,
      dayNumber: state.session!.dayNumber,
      dayTitle: state.session!.dayTitle,
      startTime: state.session!.startTime,
      endTime: DateTime.now(),
      durationSeconds: state.elapsedSeconds,
      totalVolumeKg: totalVolume,
      totalSetsCompleted: completedSets,
      caloriesBurned: calories,
      exercises: state.session!.exercises,
    );

    final repo = _ref.read(workoutRepositoryProvider);
    await repo.saveWorkoutSession(finalSession);

    state = const ActiveWorkoutState();
    return finalSession;
  }

  void cancelSession() {
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    state = const ActiveWorkoutState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
}

final activeWorkoutControllerProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>((ref) {
  return ActiveWorkoutNotifier(ref);
});
