import 'fitness_enums.dart';

/// Full Fitness and User Profile model mapped to Firestore `users/{uid}`.
class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime? dateOfBirth;
  final BiologicalSex sexForBmr;
  final double heightCm;
  final double currentWeightKg;
  final double? targetWeightKg;
  final ActivityLevel activityLevel;
  final FitnessGoal fitnessGoal;
  final ExperienceLevel experienceLevel;
  final int weeklyWorkoutFrequency;
  final List<String> availableEquipment;
  final int preferredWorkoutDurationMinutes;
  final double bmrEstimate;
  final double tdeeEstimate;
  final double dailyCalorieTarget;
  final bool profileCompleted;
  final String role; // 'admin', 'staff', 'member'
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.dateOfBirth,
    this.sexForBmr = BiologicalSex.male,
    this.heightCm = 0.0,
    this.currentWeightKg = 0.0,
    this.targetWeightKg,
    this.activityLevel = ActivityLevel.moderatelyActive,
    this.fitnessGoal = FitnessGoal.maintain,
    this.experienceLevel = ExperienceLevel.beginner,
    this.weeklyWorkoutFrequency = 3,
    this.availableEquipment = const [],
    this.preferredWorkoutDurationMinutes = 45,
    this.bmrEstimate = 0.0,
    this.tdeeEstimate = 0.0,
    this.dailyCalorieTarget = 0.0,
    this.profileCompleted = false,
    this.role = 'member',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Role helpers
  bool get isAdmin => role == 'admin' || email.toLowerCase().contains('admin');
  bool get isStaff =>
      role == 'staff' ||
      role == 'petugas' ||
      email.toLowerCase().contains('petugas') ||
      email.toLowerCase().contains('staff');
  bool get isStaffOrAdmin => isAdmin || isStaff;

  /// Calculates user age in years from dateOfBirth or fallback.
  int get calculatedAge {
    if (dateOfBirth == null) return 25;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Creates a blank profile instance for new accounts
  factory UserProfile.empty({
    required String uid,
    required String email,
    required String displayName,
    String? role,
  }) {
    final now = DateTime.now();
    final lowerEmail = email.toLowerCase();
    final effectiveRole = role ??
        (lowerEmail.contains('admin')
            ? 'admin'
            : (lowerEmail.contains('petugas') || lowerEmail.contains('staff')
                ? 'staff'
                : 'member'));
    final isStaffOrAdmin =
        effectiveRole == 'admin' || effectiveRole == 'staff';

    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      role: effectiveRole,
      profileCompleted: isStaffOrAdmin,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    final email = map['email'] as String? ?? '';
    final lowerEmail = email.toLowerCase();
    final parsedRole = map['role'] as String? ??
        (lowerEmail.contains('admin')
            ? 'admin'
            : (lowerEmail.contains('petugas') || lowerEmail.contains('staff')
                ? 'staff'
                : 'member'));

    return UserProfile(
      uid: uid,
      email: email,
      displayName: map['displayName'] as String? ?? 'User',
      photoUrl: map['photoUrl'] as String?,
      role: parsedRole,
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.tryParse(map['dateOfBirth'].toString())
          : null,
      sexForBmr: BiologicalSex.fromCode(map['sexForBmr'] as String? ?? 'male'),
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 0.0,
      currentWeightKg: (map['currentWeightKg'] as num?)?.toDouble() ?? 0.0,
      targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble(),
      activityLevel: ActivityLevel.fromName(
        map['activityLevel'] as String? ?? ActivityLevel.moderatelyActive.name,
      ),
      fitnessGoal: FitnessGoal.fromName(
        map['fitnessGoal'] as String? ?? FitnessGoal.maintain.name,
      ),
      experienceLevel: ExperienceLevel.fromName(
        map['experienceLevel'] as String? ?? ExperienceLevel.beginner.name,
      ),
      weeklyWorkoutFrequency: (map['weeklyWorkoutFrequency'] as num?)?.toInt() ?? 3,
      availableEquipment: (map['availableEquipment'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      preferredWorkoutDurationMinutes:
          (map['preferredWorkoutDurationMinutes'] as num?)?.toInt() ?? 45,
      bmrEstimate: (map['bmrEstimate'] as num?)?.toDouble() ?? 0.0,
      tdeeEstimate: (map['tdeeEstimate'] as num?)?.toDouble() ?? 0.0,
      dailyCalorieTarget:
          (map['dailyCalorieTarget'] as num?)?.toDouble() ?? 0.0,
      profileCompleted: map['profileCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'sexForBmr': sexForBmr.code,
      'heightCm': heightCm,
      'currentWeightKg': currentWeightKg,
      'targetWeightKg': targetWeightKg,
      'activityLevel': activityLevel.name,
      'fitnessGoal': fitnessGoal.name,
      'experienceLevel': experienceLevel.name,
      'weeklyWorkoutFrequency': weeklyWorkoutFrequency,
      'availableEquipment': availableEquipment,
      'preferredWorkoutDurationMinutes': preferredWorkoutDurationMinutes,
      'bmrEstimate': bmrEstimate,
      'tdeeEstimate': tdeeEstimate,
      'dailyCalorieTarget': dailyCalorieTarget,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? role,
    DateTime? dateOfBirth,
    BiologicalSex? sexForBmr,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    ActivityLevel? activityLevel,
    FitnessGoal? fitnessGoal,
    ExperienceLevel? experienceLevel,
    int? weeklyWorkoutFrequency,
    List<String>? availableEquipment,
    int? preferredWorkoutDurationMinutes,
    double? bmrEstimate,
    double? tdeeEstimate,
    double? dailyCalorieTarget,
    bool? profileCompleted,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sexForBmr: sexForBmr ?? this.sexForBmr,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      weeklyWorkoutFrequency:
          weeklyWorkoutFrequency ?? this.weeklyWorkoutFrequency,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      preferredWorkoutDurationMinutes: preferredWorkoutDurationMinutes ??
          this.preferredWorkoutDurationMinutes,
      bmrEstimate: bmrEstimate ?? this.bmrEstimate,
      tdeeEstimate: tdeeEstimate ?? this.tdeeEstimate,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
