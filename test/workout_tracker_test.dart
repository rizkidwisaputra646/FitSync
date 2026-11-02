import 'package:fitsync/features/workout/data/preset_workout_programs.dart';
import 'package:fitsync/models/fitness_enums.dart';
import 'package:fitsync/models/workout_program.dart';
import 'package:fitsync/models/workout_session.dart';
import 'package:fitsync/repositories/local_workout_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Workout Program & Preset Generator Tests', () {
    test('Generates complete 30-day program for Muscle Building PPL', () {
      final program = PresetWorkoutPrograms.getProgramForGoal(
        goal: FitnessGoal.muscleBuilding,
        level: ExperienceLevel.intermediate,
      );

      expect(program.durationDays, 30);
      expect(program.days.length, 30);
      expect(program.title, contains('Hypertrophy'));

      // Verifikasi Hari 1 adalah Push
      final day1 = program.getDay(1);
      expect(day1.isRestDay, false);
      expect(day1.exercises.isNotEmpty, true);
      expect(day1.exercises.first.exerciseId, 'barbell-bench-press');

      // Verifikasi Hari 4 adalah Rest Day
      final day4 = program.getDay(4);
      expect(day4.isRestDay, true);
      expect(day4.targetMuscles, contains('Rest'));

      // Verifikasi Hari 30 valid
      final day30 = program.getDay(30);
      expect(day30.dayNumber, 30);
    });

    test('Generates complete 30-day program for Weight Loss', () {
      final program = PresetWorkoutPrograms.getProgramForGoal(
        goal: FitnessGoal.weightLoss,
        level: ExperienceLevel.beginner,
      );

      expect(program.durationDays, 30);
      expect(program.days.length, 30);
      expect(program.targetGoal, FitnessGoal.weightLoss);

      final day1 = program.getDay(1);
      expect(day1.isRestDay, false);
      expect(day1.exercises.any((e) => e.exerciseId == 'goblet-squat-dumbbell'),
          true);
    });

    test('WorkoutProgram serialization roundtrip', () {
      final program = PresetWorkoutPrograms.getProgramForGoal(
        goal: FitnessGoal.muscleBuilding,
        level: ExperienceLevel.intermediate,
      );

      final map = program.toMap();
      final restored = WorkoutProgram.fromMap(map);

      expect(restored.id, program.id);
      expect(restored.durationDays, 30);
      expect(restored.days.length, 30);
      expect(restored.getDay(1).exercises.length,
          program.getDay(1).exercises.length);
    });
  });

  group('WorkoutSession & Volume Calculation Tests', () {
    test('Calculates volume and completed sets correctly', () {
      final sessionRecord = SessionExerciseRecord(
        exerciseId: 'barbell-bench-press',
        exerciseName: 'Barbell Flat Bench Press',
        targetMuscle: 'Chest',
        sets: [
          LoggedSet(
            setNumber: 1,
            actualWeightKg: 60.0,
            actualReps: 10,
            isCompleted: true,
          ),
          LoggedSet(
            setNumber: 2,
            actualWeightKg: 70.0,
            actualReps: 8,
            isCompleted: true,
          ),
          LoggedSet(
            setNumber: 3,
            actualWeightKg: 75.0,
            actualReps: 6,
            isCompleted: false, // Tidak dihitung karena belum selesai
          ),
        ],
      );

      // Volume = (60 * 10) + (70 * 8) = 600 + 560 = 1160 kg
      expect(sessionRecord.volumeKg, 1160.0);
      expect(sessionRecord.completedSetsCount, 2);
    });

    test('Formats duration correctly', () {
      final session = WorkoutSession(
        sessionId: 'ws_test_1',
        userId: 'u1',
        programId: 'p1',
        programTitle: 'PPL',
        dayNumber: 1,
        dayTitle: 'Hari 1',
        startTime: DateTime.now(),
        durationSeconds: 2715, // 45 menit 15 detik
        totalVolumeKg: 1200.0,
        totalSetsCompleted: 12,
        caloriesBurned: 250,
        exercises: [],
      );

      expect(session.formattedDuration, '45 menit 15s');
    });

    test('WorkoutSession serialization to and from Map', () {
      final session = WorkoutSession(
        sessionId: 'ws_test_serialize',
        userId: 'user_123',
        programId: 'program_ppl',
        programTitle: '30-Day Hypertrophy Builder',
        dayNumber: 3,
        dayTitle: 'Hari 3: Leg Power',
        startTime: DateTime(2026, 10, 25, 10, 0),
        durationSeconds: 3600,
        totalVolumeKg: 3500.0,
        totalSetsCompleted: 15,
        caloriesBurned: 350,
        exercises: [
          SessionExerciseRecord(
            exerciseId: 'barbell-back-squat',
            exerciseName: 'Barbell Back Squat',
            targetMuscle: 'Legs',
            sets: [
              LoggedSet(
                setNumber: 1,
                actualWeightKg: 80.0,
                actualReps: 10,
                isCompleted: true,
              ),
            ],
          ),
        ],
      );

      final map = session.toMap();
      final restored = WorkoutSession.fromMap(map);

      expect(restored.sessionId, session.sessionId);
      expect(restored.totalVolumeKg, 3500.0);
      expect(restored.exercises.length, 1);
      expect(restored.exercises.first.sets.first.actualWeightKg, 80.0);
    });
  });

  group('LocalWorkoutRepository Tests', () {
    test('Saves and reads workout history from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalWorkoutRepository(prefs);

      expect(await repo.getCompletedWorkoutsCount('user_test'), 0);

      final testSession = WorkoutSession(
        sessionId: 'ws_repo_1',
        userId: 'user_test',
        programId: 'ppl',
        programTitle: 'PPL',
        dayNumber: 1,
        dayTitle: 'Hari 1: Push',
        startTime: DateTime.now(),
        durationSeconds: 1800,
        totalVolumeKg: 2000.0,
        totalSetsCompleted: 10,
        caloriesBurned: 180,
        exercises: [],
      );

      await repo.saveWorkoutSession(testSession);

      final history = await repo.getWorkoutHistory('user_test');
      expect(history.length, 1);
      expect(history.first.sessionId, 'ws_repo_1');
      expect(await repo.getCompletedWorkoutsCount('user_test'), 1);
    });
  });
}
