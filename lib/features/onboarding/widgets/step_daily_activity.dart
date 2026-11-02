import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/fitness_enums.dart';
import '../../../shared/widgets/fitsync_card.dart';

class StepDailyActivity extends StatelessWidget {
  final ActivityLevel selectedLevel;
  final ValueChanged<ActivityLevel> onSelect;

  const StepDailyActivity({
    super.key,
    required this.selectedLevel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Langkah 2 dari 4',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Aktivitas Harian Rutin',
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Pilihlah yang menggambarkan rutinitas harian Anda di luar sesi gym. Tingkat aktivitas menentukan total pengeluaran energi harian (TDEE).',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        ...ActivityLevel.values.map((level) {
          final isSelected = level == selectedLevel;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FitSyncCard(
              isSelected: isSelected,
              onTap: () => onSelect(level),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.textOnPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              level.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHighlight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${level.multiplier}x BMR',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          level.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? AppColors.textPrimary.withValues(alpha: 0.9)
                                : AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
