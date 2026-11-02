import 'fitness_enums.dart';

class ProgramExerciseItem {
  final String exerciseId;
  final String exerciseName;
  final String targetMuscle;
  final int targetSets;
  final String targetReps;
  final int restSeconds;
  final String? notes;

  const ProgramExerciseItem({
    required this.exerciseId,
    required this.exerciseName,
    required this.targetMuscle,
    this.targetSets = 3,
    this.targetReps = '10-12',
    this.restSeconds = 60,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'targetMuscle': targetMuscle,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'restSeconds': restSeconds,
      'notes': notes,
    };
  }

  factory ProgramExerciseItem.fromMap(Map<String, dynamic> map) {
    return ProgramExerciseItem(
      exerciseId: map['exerciseId'] as String? ?? '',
      exerciseName: map['exerciseName'] as String? ?? '',
      targetMuscle: map['targetMuscle'] as String? ?? '',
      targetSets: (map['targetSets'] as num?)?.toInt() ?? 3,
      targetReps: map['targetReps'] as String? ?? '10-12',
      restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 60,
      notes: map['notes'] as String?,
    );
  }
}

class ProgramDay {
  final int dayNumber;
  final String title;
  final bool isRestDay;
  final List<String> targetMuscles;
  final String description;
  final List<ProgramExerciseItem> exercises;

  const ProgramDay({
    required this.dayNumber,
    required this.title,
    this.isRestDay = false,
    this.targetMuscles = const [],
    this.description = '',
    this.exercises = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'title': title,
      'isRestDay': isRestDay,
      'targetMuscles': targetMuscles,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory ProgramDay.fromMap(Map<String, dynamic> map) {
    return ProgramDay(
      dayNumber: (map['dayNumber'] as num?)?.toInt() ?? 1,
      title: map['title'] as String? ?? '',
      isRestDay: map['isRestDay'] as bool? ?? false,
      targetMuscles: (map['targetMuscles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: map['description'] as String? ?? '',
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((e) =>
                  ProgramExerciseItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WorkoutProgram {
  final String id;
  final String title;
  final String description;
  final FitnessGoal targetGoal;
  final ExperienceLevel experienceLevel;
  final int durationDays;
  final List<ProgramDay> days;

  const WorkoutProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.targetGoal,
    required this.experienceLevel,
    this.durationDays = 30,
    required this.days,
  });

  ProgramDay getDay(int dayNumber) {
    return days.firstWhere(
      (d) => d.dayNumber == dayNumber,
      orElse: () => ProgramDay(
        dayNumber: dayNumber,
        title: 'Hari $dayNumber: Istirahat & Pemulihan',
        isRestDay: true,
        targetMuscles: const ['Rest'],
        description: 'Pemulihan aktif untuk pertumbuhan serat otot yang optimal.',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetGoal': targetGoal.name,
      'experienceLevel': experienceLevel.name,
      'durationDays': durationDays,
      'days': days.map((d) => d.toMap()).toList(),
    };
  }

  factory WorkoutProgram.fromMap(Map<String, dynamic> map) {
    return WorkoutProgram(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      targetGoal: FitnessGoal.values.firstWhere(
        (g) => g.name == map['targetGoal'],
        orElse: () => FitnessGoal.muscleBuilding,
      ),
      experienceLevel: ExperienceLevel.values.firstWhere(
        (e) => e.name == map['experienceLevel'],
        orElse: () => ExperienceLevel.intermediate,
      ),
      durationDays: (map['durationDays'] as num?)?.toInt() ?? 30,
      days: (map['days'] as List<dynamic>?)
              ?.map((d) => ProgramDay.fromMap(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
