import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/fitness_enums.dart';
import '../../../shared/widgets/fitsync_card.dart';
import '../../../shared/widgets/fitsync_text_field.dart';

class StepFitnessGoals extends StatefulWidget {
  final FitnessGoal initialGoal;
  final double? initialTargetWeight;
  final ExperienceLevel initialExperience;
  final int initialFrequency;
  final List<String> initialEquipment;
  final int initialDuration;
  final Function({
    required FitnessGoal goal,
    double? targetWeightKg,
    required ExperienceLevel experienceLevel,
    required int weeklyFrequency,
    required List<String> equipment,
    required int preferredDuration,
  }) onValidSubmit;

  const StepFitnessGoals({
    super.key,
    required this.initialGoal,
    this.initialTargetWeight,
    required this.initialExperience,
    required this.initialFrequency,
    required this.initialEquipment,
    required this.initialDuration,
    required this.onValidSubmit,
  });

  @override
  State<StepFitnessGoals> createState() => _StepFitnessGoalsState();
}

class _StepFitnessGoalsState extends State<StepFitnessGoals> {
  late FitnessGoal _selectedGoal;
  late TextEditingController _targetWeightController;
  late ExperienceLevel _selectedExperience;
  late int _weeklyFrequency;
  late List<String> _selectedEquipment;
  late int _preferredDuration;

  final List<String> _allEquipment = [
    'Barbell',
    'Dumbbell',
    'Cable Machine',
    'Smith Machine',
    'Bench',
    'Leg Press Machine',
    'Lat Pulldown Machine',
    'Kettlebell',
    'Bodyweight',
  ];

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.initialGoal;
    _targetWeightController = TextEditingController(
      text: widget.initialTargetWeight != null
          ? widget.initialTargetWeight!.toStringAsFixed(1)
          : '',
    );
    _selectedExperience = widget.initialExperience;
    _weeklyFrequency = widget.initialFrequency;
    _selectedEquipment = List.from(widget.initialEquipment);
    _preferredDuration = widget.initialDuration;
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  void validateAndProceed() {
    final targetWeight = double.tryParse(_targetWeightController.text.trim());
    widget.onValidSubmit(
      goal: _selectedGoal,
      targetWeightKg: targetWeight,
      experienceLevel: _selectedExperience,
      weeklyFrequency: _weeklyFrequency,
      equipment: _selectedEquipment,
      preferredDuration: _preferredDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Langkah 3 dari 4',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tujuan & Preferensi Latihan',
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Data ini digunakan untuk menentukan rekomendasi program latihan dan penyesuaian target kalori.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        // Pilihan Tujuan Utama
        Text(
          'Tujuan Utama',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        ...FitnessGoal.values.map((goal) {
          final isSelected = goal == _selectedGoal;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FitSyncCard(
              isSelected: isSelected,
              onTap: () => setState(() => _selectedGoal = goal),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    goal == FitnessGoal.weightLoss
                        ? Icons.trending_down_rounded
                        : goal == FitnessGoal.muscleBuilding
                            ? Icons.fitness_center_rounded
                            : Icons.balance_rounded,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          goal.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
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
        const SizedBox(height: 16),

        // Target Berat Badan (jika goal bukan maintain)
        if (_selectedGoal != FitnessGoal.maintain) ...[
          FitSyncTextField(
            controller: _targetWeightController,
            label: 'Target Berat Badan (kg) — Opsional',
            hint: 'Contoh: 62.0',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 18),
        ],

        // Level Pengalaman
        Text(
          'Pengalaman Latihan Beban',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Row(
          children: ExperienceLevel.values.map((exp) {
            final isSelected = exp == _selectedExperience;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FitSyncCard(
                  isSelected: isSelected,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  onTap: () => setState(() => _selectedExperience = exp),
                  child: Center(
                    child: Text(
                      exp.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Frekuensi Latihan per Minggu
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Frekuensi Latihan per Minggu',
              style: theme.textTheme.titleMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_weeklyFrequency Hari',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: _weeklyFrequency.toDouble(),
          min: 2,
          max: 6,
          divisions: 4,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.surfaceElevated,
          onChanged: (val) {
            setState(() => _weeklyFrequency = val.round());
          },
        ),
        const SizedBox(height: 12),

        // Durasi Sesi yang Diinginkan
        Text(
          'Target Durasi Sesi Latihan',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Row(
          children: [30, 45, 60, 90].map((duration) {
            final isSelected = duration == _preferredDuration;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FitSyncCard(
                  isSelected: isSelected,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onTap: () => setState(() => _preferredDuration = duration),
                  child: Center(
                    child: Text(
                      '$duration mnt',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Peralatan yang Tersedia
        Text(
          'Peralatan Gym yang Digunakan',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allEquipment.map((item) {
            final isSelected = _selectedEquipment.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedEquipment.add(item);
                  } else {
                    _selectedEquipment.remove(item);
                  }
                });
              },
              backgroundColor: AppColors.surfaceElevated,
              selectedColor: AppColors.primaryContainer,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
