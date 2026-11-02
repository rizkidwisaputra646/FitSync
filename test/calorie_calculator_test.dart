import 'package:flutter_test/flutter_test.dart';
import 'package:fitsync/core/calculators/calorie_calculator.dart';
import 'package:fitsync/core/calculators/models/calculation_result.dart';
import 'package:fitsync/models/fitness_enums.dart';

void main() {
  group('CalorieCalculator Tests', () {
    test('Calculates male BMR correctly using Mifflin-St Jeor', () {
      // Male: 25 years, 75 kg, 175 cm
      // Formula: (10 * 75) + (6.25 * 175) - (5 * 25) + 5
      // = 750 + 1093.75 - 125 + 5 = 1723.75
      final bmr = CalorieCalculator.calculateBmr(
        weightKg: 75,
        heightCm: 175,
        age: 25,
        sex: BiologicalSex.male,
      );

      expect(bmr, closeTo(1723.75, 0.01));
    });

    test('Calculates female BMR correctly using Mifflin-St Jeor', () {
      // Female: 28 years, 60 kg, 162 cm
      // Formula: (10 * 60) + (6.25 * 162) - (5 * 28) - 161
      // = 600 + 1012.5 - 140 - 161 = 1311.5
      final bmr = CalorieCalculator.calculateBmr(
        weightKg: 60,
        heightCm: 162,
        age: 28,
        sex: BiologicalSex.female,
      );

      expect(bmr, closeTo(1311.5, 0.01));
    });

    test('Calculates TDEE correctly according to activity level multipliers', () {
      const bmr = 1500.0;
      expect(
        CalorieCalculator.calculateTdee(bmr: bmr, activityLevel: ActivityLevel.sedentary),
        closeTo(1800.0, 0.01), // 1500 * 1.2
      );
      expect(
        CalorieCalculator.calculateTdee(bmr: bmr, activityLevel: ActivityLevel.moderatelyActive),
        closeTo(2325.0, 0.01), // 1500 * 1.55
      );
      expect(
        CalorieCalculator.calculateTdee(bmr: bmr, activityLevel: ActivityLevel.extraActive),
        closeTo(2850.0, 0.01), // 1500 * 1.9
      );
    });

    test('Calculates BMI and assigns correct BMI category', () {
      // 70 kg, 175 cm -> 70 / (1.75^2) = 22.86 (Normal)
      final bmi = CalorieCalculator.calculateBmi(weightKg: 70, heightCm: 175);
      expect(bmi, closeTo(22.86, 0.05));
      expect(CalorieCalculator.getBmiCategory(bmi), BmiCategory.normal);

      // Underweight (< 18.5)
      expect(CalorieCalculator.getBmiCategory(17.5), BmiCategory.underweight);
      // Overweight (25 - 29.9)
      expect(CalorieCalculator.getBmiCategory(27.0), BmiCategory.overweight);
      // Obese (>= 30)
      expect(CalorieCalculator.getBmiCategory(32.4), BmiCategory.obese);
    });

    test('Applies safe non-restrictive policy for underage users (< 18)', () {
      final result = CalorieCalculator.calculateAll(
        weightKg: 65,
        heightCm: 170,
        age: 16,
        sex: BiologicalSex.male,
        activityLevel: ActivityLevel.moderatelyActive,
        goal: FitnessGoal.weightLoss,
      );

      expect(result.isUnderage, isTrue);
      expect(result.safetyNotice, isNotNull);
      // Underage weight-loss should not enforce dangerous calorie restriction
      expect(result.dailyCalorieTarget, equals(result.tdee));
    });

    test('Validates input ranges correctly', () {
      expect(
        CalorieCalculator.validateInputs(heightCm: 40, weightKg: 70, age: 25),
        isNotNull,
      );
      expect(
        CalorieCalculator.validateInputs(heightCm: 170, weightKg: 10, age: 25),
        isNotNull,
      );
      expect(
        CalorieCalculator.validateInputs(heightCm: 170, weightKg: 70, age: 9),
        isNotNull,
      );
      expect(
        CalorieCalculator.validateInputs(heightCm: 175, weightKg: 70, age: 25),
        isNull,
      );
    });
  });
}
