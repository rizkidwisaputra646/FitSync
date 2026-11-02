import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/calculators/models/calculation_result.dart';
import '../../../models/fitness_enums.dart';
import '../../../shared/widgets/fitsync_card.dart';

class StepCalculationResults extends StatelessWidget {
  final CalculationResult result;
  final double currentWeightKg;
  final double heightCm;
  final int age;
  final BiologicalSex sex;
  final ActivityLevel activityLevel;
  final FitnessGoal goal;

  const StepCalculationResults({
    super.key,
    required this.result,
    required this.currentWeightKg,
    required this.heightCm,
    required this.age,
    required this.sex,
    required this.activityLevel,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Langkah 4 dari 4',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hasil Analisis Metabolik',
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Berdasarkan data fisik dan aktivitas rutin Anda, berikut adalah kalkulasi kebutuhan energi harian:',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        // Hero Card: Target Kalori Harian
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E2B16), Color(0xFF15221B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.8),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  goal.title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${result.dailyCalorieTarget.round()}',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Kkal / Hari',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                goal == FitnessGoal.weightLoss
                    ? 'Defisit moderat (~400 kkal dari TDEE) untuk pembakaran lemak berkelanjutan tanpa merusak metabolisme.'
                    : goal == FitnessGoal.muscleBuilding
                        ? 'Surplus moderat (+250 kkal dari TDEE) untuk menyuplai pembentukan jaringan otot baru.'
                        : 'Pemeliharaan seimbang sesuai pengeluaran energi harian.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12.5,
                  color: AppColors.textPrimary.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Grid 2 Kolom: BMR & TDEE
        Row(
          children: [
            Expanded(
              child: FitSyncCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMR (Basal)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${result.bmr.round()} kkal',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Energi saat istirahat total.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FitSyncCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TDEE (Total)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${result.tdee.round()} kkal',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Energi harian + aktivitas.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // BMI Card
        FitSyncCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Indeks Massa Tubuh (BMI)',
                    style: theme.textTheme.titleMedium,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${result.bmi.toStringAsFixed(1)} — ${result.bmiCategory.label}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Catatan: BMI adalah indikator populasi umum, bukan diagnosis komposisi tubuh langsung. Individu dengan massa otot tinggi sering kali memiliki BMI lebih tinggi tanpa kelebihan lemak tubuh.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Underage safety notice jika berlaku
        if (result.safetyNotice != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.safetyNotice!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // General disclaimer
        Text(
          result.disclaimer,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
