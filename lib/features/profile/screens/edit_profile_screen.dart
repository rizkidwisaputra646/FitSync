import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/fitness_enums.dart';
import '../../../models/user_profile.dart';
import '../../../shared/widgets/fitsync_button.dart';
import '../../../shared/widgets/fitsync_card.dart';
import '../../../shared/widgets/fitsync_text_field.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;

  late BiologicalSex _selectedSex;
  late ActivityLevel _selectedActivity;
  late FitnessGoal _selectedGoal;
  late ExperienceLevel _selectedExperience;
  late int _weeklyFrequency;
  late int _preferredDuration;
  late List<String> _selectedEquipment;

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
    final p = widget.profile;
    _nameController = TextEditingController(text: p.displayName);
    _ageController = TextEditingController(text: p.calculatedAge.toString());
    _heightController =
        TextEditingController(text: p.heightCm.toStringAsFixed(0));
    _weightController =
        TextEditingController(text: p.currentWeightKg.toStringAsFixed(1));
    _targetWeightController = TextEditingController(
      text: p.targetWeightKg != null ? p.targetWeightKg!.toStringAsFixed(1) : '',
    );

    _selectedSex = p.sexForBmr;
    _selectedActivity = p.activityLevel;
    _selectedGoal = p.fitnessGoal;
    _selectedExperience = p.experienceLevel;
    _weeklyFrequency = p.weeklyWorkoutFrequency;
    _preferredDuration = p.preferredWorkoutDurationMinutes;
    _selectedEquipment = List<String>.from(p.availableEquipment);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final age = int.parse(_ageController.text.trim());
    final height = double.parse(_heightController.text.trim());
    final weight = double.parse(_weightController.text.trim());
    final targetWeight = double.tryParse(_targetWeightController.text.trim());

    FocusScope.of(context).unfocus();

    await ref.read(profileEditControllerProvider.notifier).updateProfile(
          displayName: _nameController.text.trim(),
          heightCm: height,
          currentWeightKg: weight,
          targetWeightKg: targetWeight,
          age: age,
          sex: _selectedSex,
          activityLevel: _selectedActivity,
          fitnessGoal: _selectedGoal,
          experienceLevel: _selectedExperience,
          weeklyFrequency: _weeklyFrequency,
          availableEquipment: _selectedEquipment,
          preferredDuration: _preferredDuration,
        );

    final state = ref.read(profileEditControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Profil & estimasi metabolisme (BMR/TDEE) berhasil diperbarui.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editState = ref.watch(profileEditControllerProvider);
    final isLoading = editState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profil & Parameter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Data Fisik & Identitas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),

                // Nama
                FitSyncTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),

                // Jenis Kelamin Biologis
                Text('Jenis Kelamin Biologis (Rumus BMR)',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FitSyncCard(
                        isSelected: _selectedSex == BiologicalSex.male,
                        onTap: () =>
                            setState(() => _selectedSex = BiologicalSex.male),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Laki-laki',
                            style: TextStyle(
                              color: _selectedSex == BiologicalSex.male
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FitSyncCard(
                        isSelected: _selectedSex == BiologicalSex.female,
                        onTap: () =>
                            setState(() => _selectedSex = BiologicalSex.female),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Perempuan',
                            style: TextStyle(
                              color: _selectedSex == BiologicalSex.female
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Umur
                FitSyncTextField(
                  controller: _ageController,
                  label: 'Umur (Tahun)',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final age = int.tryParse(v ?? '');
                    if (age == null || age < 12 || age > 110) {
                      return 'Masukkan umur 12-110 tahun';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Tinggi & Berat
                Row(
                  children: [
                    Expanded(
                      child: FitSyncTextField(
                        controller: _heightController,
                        label: 'Tinggi (cm)',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          final h = double.tryParse(v ?? '');
                          if (h == null || h < 80 || h > 260) {
                            return 'Rentang 80-260 cm';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FitSyncTextField(
                        controller: _weightController,
                        label: 'Berat (kg)',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          final w = double.tryParse(v ?? '');
                          if (w == null || w < 25 || w > 350) {
                            return 'Rentang 25-350 kg';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Target Berat Badan
                FitSyncTextField(
                  controller: _targetWeightController,
                  label: 'Target Berat Badan (kg) — Opsional',
                  hint: 'Contoh: 65.0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 24),

                // Tingkat Aktivitas Harian
                Text(
                  'Aktivitas Harian Rutin (Pengali TDEE)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...ActivityLevel.values.map((lvl) {
                  final isSelected = lvl == _selectedActivity;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FitSyncCard(
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedActivity = lvl),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lvl.title,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  lvl.description,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${lvl.multiplier}x',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Tujuan Fitness
                Text(
                  'Tujuan Kebugaran',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...FitnessGoal.values.map((g) {
                  final isSelected = g == _selectedGoal;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FitSyncCard(
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedGoal = g),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            g == FitnessGoal.weightLoss
                                ? Icons.trending_down_rounded
                                : g == FitnessGoal.muscleBuilding
                                    ? Icons.fitness_center_rounded
                                    : Icons.balance_rounded,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              g.title,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Level Pengalaman
                Text('Level Pengalaman Gym',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: ExperienceLevel.values.map((exp) {
                    final isSelected = exp == _selectedExperience;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FitSyncCard(
                          isSelected: isSelected,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onTap: () => setState(() => _selectedExperience = exp),
                          child: Center(
                            child: Text(
                              exp.title,
                              style: TextStyle(
                                fontSize: 12,
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

                // Frekuensi Per Minggu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Frekuensi Latihan / Minggu',
                        style: theme.textTheme.titleMedium),
                    Text(
                      '$_weeklyFrequency Hari',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
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
                  onChanged: (val) {
                    setState(() => _weeklyFrequency = val.round());
                  },
                ),
                const SizedBox(height: 20),

                // Peralatan Gym yang Digunakan
                Text(
                  'Peralatan Gym yang Digunakan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
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
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color:
                              isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Save Button
                FitSyncButton(
                  text: 'Simpan & Hitung Ulang Target',
                  isLoading: isLoading,
                  onPressed: _save,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
