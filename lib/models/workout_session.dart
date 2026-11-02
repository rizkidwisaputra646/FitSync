class LoggedSet {
  final int setNumber;
  final int targetReps;
  int actualReps;
  double actualWeightKg;
  bool isCompleted;

  LoggedSet({
    required this.setNumber,
    this.targetReps = 10,
    this.actualReps = 10,
    this.actualWeightKg = 0.0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'targetReps': targetReps,
      'actualReps': actualReps,
      'actualWeightKg': actualWeightKg,
      'isCompleted': isCompleted,
    };
  }

  factory LoggedSet.fromMap(Map<String, dynamic> map) {
    return LoggedSet(
      setNumber: (map['setNumber'] as num?)?.toInt() ?? 1,
      targetReps: (map['targetReps'] as num?)?.toInt() ?? 10,
      actualReps: (map['actualReps'] as num?)?.toInt() ?? 10,
      actualWeightKg: (map['actualWeightKg'] as num?)?.toDouble() ?? 0.0,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  LoggedSet copyWith({
    int? setNumber,
    int? targetReps,
    int? actualReps,
    double? actualWeightKg,
    bool? isCompleted,
  }) {
    return LoggedSet(
      setNumber: setNumber ?? this.setNumber,
      targetReps: targetReps ?? this.targetReps,
      actualReps: actualReps ?? this.actualReps,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class SessionExerciseRecord {
  final String exerciseId;
  final String exerciseName;
  final String targetMuscle;
  final List<LoggedSet> sets;

  const SessionExerciseRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.targetMuscle,
    required this.sets,
  });

  double get volumeKg {
    double total = 0.0;
    for (final s in sets) {
      if (s.isCompleted) {
        total += (s.actualWeightKg * s.actualReps);
      }
    }
    return total;
  }

  int get completedSetsCount {
    return sets.where((s) => s.isCompleted).length;
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'targetMuscle': targetMuscle,
      'sets': sets.map((s) => s.toMap()).toList(),
    };
  }

  factory SessionExerciseRecord.fromMap(Map<String, dynamic> map) {
    return SessionExerciseRecord(
      exerciseId: map['exerciseId'] as String? ?? '',
      exerciseName: map['exerciseName'] as String? ?? '',
      targetMuscle: map['targetMuscle'] as String? ?? '',
      sets: (map['sets'] as List<dynamic>?)
              ?.map((s) => LoggedSet.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WorkoutSession {
  final String sessionId;
  final String userId;
  final String programId;
  final String programTitle;
  final int dayNumber;
  final String dayTitle;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final double totalVolumeKg;
  final int totalSetsCompleted;
  final int caloriesBurned;
  final List<SessionExerciseRecord> exercises;
  final String? notes;

  const WorkoutSession({
    required this.sessionId,
    required this.userId,
    required this.programId,
    required this.programTitle,
    required this.dayNumber,
    required this.dayTitle,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.totalVolumeKg,
    required this.totalSetsCompleted,
    required this.caloriesBurned,
    required this.exercises,
    this.notes,
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remMinutes = minutes % 60;
      return '${hours}j ${remMinutes}m';
    }
    return '$minutes menit ${seconds}s';
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'programId': programId,
      'programTitle': programTitle,
      'dayNumber': dayNumber,
      'dayTitle': dayTitle,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'totalVolumeKg': totalVolumeKg,
      'totalSetsCompleted': totalSetsCompleted,
      'caloriesBurned': caloriesBurned,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'notes': notes,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      sessionId: map['sessionId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      programId: map['programId'] as String? ?? '',
      programTitle: map['programTitle'] as String? ?? '',
      dayNumber: (map['dayNumber'] as num?)?.toInt() ?? 1,
      dayTitle: map['dayTitle'] as String? ?? '',
      startTime: DateTime.tryParse(map['startTime'] as String? ?? '') ??
          DateTime.now(),
      endTime: map['endTime'] != null
          ? DateTime.tryParse(map['endTime'] as String)
          : null,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      totalVolumeKg: (map['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
      totalSetsCompleted:
          (map['totalSetsCompleted'] as num?)?.toInt() ?? 0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toInt() ?? 0,
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((e) =>
                  SessionExerciseRecord.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: map['notes'] as String?,
    );
  }
}
