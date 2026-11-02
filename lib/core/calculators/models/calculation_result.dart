import 'package:flutter/foundation.dart';

/// Categories for Body Mass Index (BMI).
enum BmiCategory {
  underweight('Berat Badan Kurang', '< 18.5'),
  normal('Normal / Ideal', '18.5 – 24.9'),
  overweight('Kelebihan Berat Badan', '25.0 – 29.9'),
  obese('Obesitas', '≥ 30.0');

  final String label;
  final String range;
  const BmiCategory(this.label, this.range);
}

/// Immutable result of the fitness and calorie calculation.
@immutable
class CalculationResult {
  final double bmr;
  final double tdee;
  final double dailyCalorieTarget;
  final double bmi;
  final BmiCategory bmiCategory;
  final bool isUnderage;
  final String? safetyNotice;
  final String disclaimer;

  const CalculationResult({
    required this.bmr,
    required this.tdee,
    required this.dailyCalorieTarget,
    required this.bmi,
    required this.bmiCategory,
    required this.isUnderage,
    this.safetyNotice,
    required this.disclaimer,
  });

  Map<String, dynamic> toMap() {
    return {
      'bmr': bmr.round(),
      'tdee': tdee.round(),
      'dailyCalorieTarget': dailyCalorieTarget.round(),
      'bmi': double.parse(bmi.toStringAsFixed(1)),
      'bmiCategory': bmiCategory.name,
      'isUnderage': isUnderage,
    };
  }
}
