/// Model representasi data gerakan gym di FitSync.
class Exercise {
  final String id;
  final String name;
  final String targetMuscle;
  final List<String> secondaryMuscles;
  final String equipment;
  final String difficulty; // Beginner, Intermediate, Advanced
  final List<String> instructions;
  final List<String> tips;
  final int recommendedSets;
  final String recommendedReps;
  final String gifUrl;
  final String? thumbnailUrl;
  final bool isActive;
  final bool isCustom;

  const Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    this.secondaryMuscles = const [],
    required this.equipment,
    required this.difficulty,
    this.instructions = const [],
    this.tips = const [],
    this.recommendedSets = 3,
    this.recommendedReps = '10-12 Reps',
    required this.gifUrl,
    this.thumbnailUrl,
    this.isActive = true,
    this.isCustom = false,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? targetMuscle,
    List<String>? secondaryMuscles,
    String? equipment,
    String? difficulty,
    List<String>? instructions,
    List<String>? tips,
    int? recommendedSets,
    String? recommendedReps,
    String? gifUrl,
    String? thumbnailUrl,
    bool? isActive,
    bool? isCustom,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      recommendedSets: recommendedSets ?? this.recommendedSets,
      recommendedReps: recommendedReps ?? this.recommendedReps,
      gifUrl: gifUrl ?? this.gifUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isActive: isActive ?? this.isActive,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  factory Exercise.fromMap(Map<String, dynamic> map, String id) {
    return Exercise(
      id: id,
      name: map['name'] as String? ?? 'Gerakan Gym',
      targetMuscle: map['targetMuscle'] as String? ?? 'Full Body',
      secondaryMuscles: (map['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      equipment: map['equipment'] as String? ?? 'Bodyweight',
      difficulty: map['difficulty'] as String? ?? 'Beginner',
      instructions: (map['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      tips: (map['tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      recommendedSets: (map['recommendedSets'] as num?)?.toInt() ?? 3,
      recommendedReps: map['recommendedReps'] as String? ?? '10-12 Reps',
      gifUrl: map['gifUrl'] as String? ?? '',
      thumbnailUrl: map['thumbnailUrl'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetMuscle': targetMuscle,
      'secondaryMuscles': secondaryMuscles,
      'equipment': equipment,
      'difficulty': difficulty,
      'instructions': instructions,
      'tips': tips,
      'recommendedSets': recommendedSets,
      'recommendedReps': recommendedReps,
      'gifUrl': gifUrl,
      'thumbnailUrl': thumbnailUrl,
      'isActive': isActive,
      'isCustom': isCustom,
    };
  }
}
