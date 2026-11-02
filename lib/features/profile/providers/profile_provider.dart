import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/calculators/calorie_calculator.dart';
import '../../../models/fitness_enums.dart';
import '../../../models/user_profile.dart';
import '../../../models/weight_log_entry.dart';
import '../../../repositories/user_repository.dart';
import '../../auth/providers/auth_provider.dart';

final weightLogsProvider = StreamProvider<List<WeightLogEntry>>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) {
    return Stream.value(const []);
  }
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.watchWeightLogs(authState.uid);
});

class ProfileEditController extends StateNotifier<AsyncValue<void>> {
  final UserRepository _userRepo;
  final Ref _ref;

  ProfileEditController(this._userRepo, this._ref)
      : super(const AsyncValue.data(null));

  /// Memperbarui data profil lengkap dan menghitung ulang BMR/TDEE/Kalori secara otomatis
  Future<void> updateProfile({
    required String displayName,
    required double heightCm,
    required double currentWeightKg,
    double? targetWeightKg,
    required int age,
    required BiologicalSex sex,
    required ActivityLevel activityLevel,
    required FitnessGoal fitnessGoal,
    required ExperienceLevel experienceLevel,
    required int weeklyFrequency,
    required List<String> availableEquipment,
    required int preferredDuration,
  }) async {
    final currentSession = _ref.read(authStateProvider).value;
    if (currentSession == null) {
      throw 'Sesi pengguna tidak valid.';
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. Hitung ulang BMR, TDEE, dan Target Kalori yang konsisten dengan input baru
      final calcResult = CalorieCalculator.calculateAll(
        weightKg: currentWeightKg,
        heightCm: heightCm,
        age: age,
        sex: sex,
        activityLevel: activityLevel,
        goal: fitnessGoal,
      );

      final now = DateTime.now();
      final birthDate = DateTime(now.year - age, now.month, now.day);

      final updatedProfile = UserProfile(
        uid: currentSession.uid,
        email: currentSession.email,
        displayName: displayName.trim(),
        dateOfBirth: birthDate,
        sexForBmr: sex,
        heightCm: heightCm,
        currentWeightKg: currentWeightKg,
        targetWeightKg: targetWeightKg,
        activityLevel: activityLevel,
        fitnessGoal: fitnessGoal,
        experienceLevel: experienceLevel,
        weeklyWorkoutFrequency: weeklyFrequency,
        availableEquipment: availableEquipment,
        preferredWorkoutDurationMinutes: preferredDuration,
        bmrEstimate: calcResult.bmr,
        tdeeEstimate: calcResult.tdee,
        dailyCalorieTarget: calcResult.dailyCalorieTarget,
        profileCompleted: true,
        createdAt: now,
        updatedAt: now,
      );

      await _userRepo.saveUserProfile(updatedProfile);
    });
  }

  /// Mencatat entri berat badan baru tanpa menimpa histori lama, sekaligus memperbarui profil dan kalkulasi kalori
  Future<void> logNewWeight({
    required double newWeightKg,
    String? note,
  }) async {
    final currentSession = _ref.read(authStateProvider).value;
    if (currentSession == null) {
      throw 'Sesi pengguna tidak valid.';
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. Catat ke weightLogs
      await _userRepo.updateWeightLog(
        uid: currentSession.uid,
        newWeightKg: newWeightKg,
        note: note,
      );

      // 2. Ambil profil saat ini untuk recalculate parameter metabolisme
      final profile = await _userRepo.getUserProfile(currentSession.uid);
      if (profile != null) {
        final calcResult = CalorieCalculator.calculateAll(
          weightKg: newWeightKg,
          heightCm: profile.heightCm,
          age: profile.calculatedAge,
          sex: profile.sexForBmr,
          activityLevel: profile.activityLevel,
          goal: profile.fitnessGoal,
        );

        final updatedProfile = profile.copyWith(
          currentWeightKg: newWeightKg,
          bmrEstimate: calcResult.bmr,
          tdeeEstimate: calcResult.tdee,
          dailyCalorieTarget: calcResult.dailyCalorieTarget,
          updatedAt: DateTime.now(),
        );

        await _userRepo.saveUserProfile(updatedProfile);
      }
    });
  }
}

final profileEditControllerProvider =
    StateNotifierProvider<ProfileEditController, AsyncValue<void>>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return ProfileEditController(userRepo, ref);
});
