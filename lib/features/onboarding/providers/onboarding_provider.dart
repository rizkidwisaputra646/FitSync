import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/calculators/calorie_calculator.dart';
import '../../../core/calculators/models/calculation_result.dart';
import '../../../models/fitness_enums.dart';
import '../../../models/user_profile.dart';
import '../../auth/providers/auth_provider.dart';

class OnboardingState {
  final int currentStep; // 1 to 4
  final String fullName;
  final int age;
  final BiologicalSex sex;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final FitnessGoal fitnessGoal;
  final double? targetWeightKg;
  final ExperienceLevel experienceLevel;
  final int weeklyWorkoutFrequency;
  final List<String> availableEquipment;
  final int preferredWorkoutDurationMinutes;
  final CalculationResult? calculationResult;
  final bool isSaving;
  final String? errorMessage;

  const OnboardingState({
    this.currentStep = 1,
    this.fullName = '',
    this.age = 24,
    this.sex = BiologicalSex.male,
    this.heightCm = 170.0,
    this.weightKg = 68.0,
    this.activityLevel = ActivityLevel.moderatelyActive,
    this.fitnessGoal = FitnessGoal.maintain,
    this.targetWeightKg,
    this.experienceLevel = ExperienceLevel.beginner,
    this.weeklyWorkoutFrequency = 3,
    this.availableEquipment = const ['Barbell', 'Dumbbell', 'Cable Machine', 'Bench'],
    this.preferredWorkoutDurationMinutes = 45,
    this.calculationResult,
    this.isSaving = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    int? currentStep,
    String? fullName,
    int? age,
    BiologicalSex? sex,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    FitnessGoal? fitnessGoal,
    double? targetWeightKg,
    ExperienceLevel? experienceLevel,
    int? weeklyWorkoutFrequency,
    List<String>? availableEquipment,
    int? preferredWorkoutDurationMinutes,
    CalculationResult? calculationResult,
    bool? isSaving,
    String? errorMessage,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      weeklyWorkoutFrequency:
          weeklyWorkoutFrequency ?? this.weeklyWorkoutFrequency,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      preferredWorkoutDurationMinutes: preferredWorkoutDurationMinutes ??
          this.preferredWorkoutDurationMinutes,
      calculationResult: calculationResult ?? this.calculationResult,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(const OnboardingState()) {
    _initializeFromCurrentAuth();
  }

  void _initializeFromCurrentAuth() {
    final user = _ref.read(authStateProvider).value;
    if (user != null) {
      state = state.copyWith(
        fullName: user.displayName.isNotEmpty
            ? user.displayName
            : user.email.split('@').first,
      );
    }
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void updatePersonalData({
    required String fullName,
    required int age,
    required BiologicalSex sex,
    required double heightCm,
    required double weightKg,
  }) {
    state = state.copyWith(
      fullName: fullName,
      age: age,
      sex: sex,
      heightCm: heightCm,
      weightKg: weightKg,
    );
  }

  void updateDailyActivity(ActivityLevel level) {
    state = state.copyWith(activityLevel: level);
  }

  void updateFitnessGoals({
    required FitnessGoal goal,
    double? targetWeightKg,
    required ExperienceLevel experienceLevel,
    required int weeklyFrequency,
    required List<String> equipment,
    required int preferredDuration,
  }) {
    state = state.copyWith(
      fitnessGoal: goal,
      targetWeightKg: targetWeightKg,
      experienceLevel: experienceLevel,
      weeklyWorkoutFrequency: weeklyFrequency,
      availableEquipment: equipment,
      preferredWorkoutDurationMinutes: preferredDuration,
    );

    // Otomatis hitung kalkulasi saat selesai langkah 3 menuju langkah 4
    computeCalculations();
  }

  void computeCalculations() {
    try {
      final result = CalorieCalculator.calculateAll(
        weightKg: state.weightKg,
        heightCm: state.heightCm,
        age: state.age,
        sex: state.sex,
        activityLevel: state.activityLevel,
        goal: state.fitnessGoal,
      );
      state = state.copyWith(calculationResult: result, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<bool> saveProfileAndFinish() async {
    final session = _ref.read(authStateProvider).value;
    if (session == null) {
      state = state.copyWith(errorMessage: 'Sesi login tidak ditemukan.');
      return false;
    }

    computeCalculations();
    final result = state.calculationResult;
    if (result == null) {
      state = state.copyWith(errorMessage: 'Kalkulasi belum selesai.');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final now = DateTime.now();
      final birthDate = DateTime(now.year - state.age, now.month, now.day);

      final profile = UserProfile(
        uid: session.uid,
        email: session.email,
        displayName: state.fullName.isNotEmpty
            ? state.fullName
            : session.displayName,
        dateOfBirth: birthDate,
        sexForBmr: state.sex,
        heightCm: state.heightCm,
        currentWeightKg: state.weightKg,
        targetWeightKg: state.targetWeightKg,
        activityLevel: state.activityLevel,
        fitnessGoal: state.fitnessGoal,
        experienceLevel: state.experienceLevel,
        weeklyWorkoutFrequency: state.weeklyWorkoutFrequency,
        availableEquipment: state.availableEquipment,
        preferredWorkoutDurationMinutes: state.preferredWorkoutDurationMinutes,
        bmrEstimate: result.bmr,
        tdeeEstimate: result.tdee,
        dailyCalorieTarget: result.dailyCalorieTarget,
        profileCompleted: true,
        createdAt: now,
        updatedAt: now,
      );

      final userRepo = _ref.read(userRepositoryProvider);
      await userRepo.saveUserProfile(profile);

      // Simpan juga sebagai log berat badan pertama
      await userRepo.updateWeightLog(
        uid: session.uid,
        newWeightKg: state.weightKg,
      );

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan profil: $e',
      );
      return false;
    }
  }
}

final onboardingProvider =
    StateNotifierProvider.autoDispose<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});
