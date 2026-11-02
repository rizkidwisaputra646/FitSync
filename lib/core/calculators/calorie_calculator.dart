import '../../models/fitness_enums.dart';
import 'models/calculation_result.dart';

/// Calorie and Metabolic Calculator based on the clinically validated Mifflin-St Jeor equation.
/// All logic is pure Dart and separated from UI for easy unit testing.
class CalorieCalculator {
  CalorieCalculator._();

  static const String generalDisclaimer =
      'Angka ini merupakan estimasi matematis menggunakan formula Mifflin–St Jeor '
      'dan faktor aktivitas. Hasil ini bukan pengukuran metabolisme laboratorium atau '
      'saran medis profesional.';

  /// Validates physical input ranges.
  static String? validateInputs({
    required double heightCm,
    required double weightKg,
    required int age,
  }) {
    if (heightCm < 80 || heightCm > 260) {
      return 'Tinggi badan harus berada dalam rentang wajar (80 - 260 cm).';
    }
    if (weightKg < 25 || weightKg > 350) {
      return 'Berat badan harus berada dalam rentang wajar (25 - 350 kg).';
    }
    if (age < 12 || age > 110) {
      return 'Umur harus berada dalam rentang 12 hingga 110 tahun.';
    }
    return null;
  }

  /// Calculates Basal Metabolic Rate (BMR) using Mifflin-St Jeor formula.
  /// Men:   BMR = (10 × weight_kg) + (6.25 × height_cm) - (5 × age) + 5
  /// Women: BMR = (10 × weight_kg) + (6.25 × height_cm) - (5 × age) - 161
  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required BiologicalSex sex,
  }) {
    final double base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    if (sex == BiologicalSex.male) {
      return base + 5;
    } else {
      return base - 161;
    }
  }

  /// Calculates Total Daily Energy Expenditure (TDEE).
  /// TDEE = BMR × Activity Multiplier
  static double calculateTdee({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    return bmr * activityLevel.multiplier;
  }

  /// Calculates Body Mass Index (BMI).
  /// BMI = weight_kg / (height_m ^ 2)
  static double calculateBmi({
    required double weightKg,
    required double heightCm,
  }) {
    final double heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  /// Maps numerical BMI to category.
  static BmiCategory getBmiCategory(double bmi) {
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25.0) return BmiCategory.normal;
    if (bmi < 30.0) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  /// Calculates safe daily calorie target based on goal and safety constraints.
  static CalculationResult calculateAll({
    required double weightKg,
    required double heightCm,
    required int age,
    required BiologicalSex sex,
    required ActivityLevel activityLevel,
    required FitnessGoal goal,
  }) {
    final validationError = validateInputs(
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
    );
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    final double bmr = calculateBmr(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      sex: sex,
    );

    final double tdee = calculateTdee(
      bmr: bmr,
      activityLevel: activityLevel,
    );

    final double bmi = calculateBmi(
      weightKg: weightKg,
      heightCm: heightCm,
    );

    final BmiCategory bmiCategory = getBmiCategory(bmi);

    final bool isUnderage = age < 18;

    double targetCalories = tdee + goal.calorieAdjustment;

    // Safety checks:
    // Minimum safe threshold: Women ~1200 kcal, Men ~1500 kcal, and never below BMR significantly
    final double minSafeFloor = (sex == BiologicalSex.female ? 1200.0 : 1500.0);
    if (targetCalories < minSafeFloor) {
      targetCalories = minSafeFloor;
    }

    String? safetyNotice;
    if (isUnderage) {
      safetyNotice =
          'Pengguna berusia di bawah 18 tahun masih dalam masa pertumbuhan. '
          'Target kalori tidak disetel ke defisit restriktif. '
          'Konsultasikan dengan dokter/ahli gizi untuk kebutuhan nutrisi spesifik.';
      // For underage, default to maintaining energy rather than aggressive deficit
      if (goal == FitnessGoal.weightLoss) {
        targetCalories = tdee; // maintain minimum for growth
      }
    }

    return CalculationResult(
      bmr: bmr,
      tdee: tdee,
      dailyCalorieTarget: targetCalories,
      bmi: bmi,
      bmiCategory: bmiCategory,
      isUnderage: isUnderage,
      safetyNotice: safetyNotice,
      disclaimer: generalDisclaimer,
    );
  }
}
