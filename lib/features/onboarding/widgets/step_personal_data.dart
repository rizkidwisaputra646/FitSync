import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/fitness_enums.dart';
import '../../../shared/widgets/fitsync_card.dart';
import '../../../shared/widgets/fitsync_text_field.dart';

class StepPersonalData extends StatefulWidget {
  final String initialName;
  final int initialAge;
  final BiologicalSex initialSex;
  final double initialHeight;
  final double initialWeight;
  final Function({
    required String fullName,
    required int age,
    required BiologicalSex sex,
    required double heightCm,
    required double weightKg,
  }) onValidSubmit;

  const StepPersonalData({
    super.key,
    required this.initialName,
    required this.initialAge,
    required this.initialSex,
    required this.initialHeight,
    required this.initialWeight,
    required this.onValidSubmit,
  });

  @override
  State<StepPersonalData> createState() => _StepPersonalDataState();
}

class _StepPersonalDataState extends State<StepPersonalData> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late BiologicalSex _selectedSex;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _ageController = TextEditingController(text: widget.initialAge.toString());
    _heightController =
        TextEditingController(text: widget.initialHeight.toStringAsFixed(0));
    _weightController =
        TextEditingController(text: widget.initialWeight.toStringAsFixed(1));
    _selectedSex = widget.initialSex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void validateAndProceed() {
    if (!_formKey.currentState!.validate()) return;

    final age = int.tryParse(_ageController.text.trim()) ?? 25;
    final height = double.tryParse(_heightController.text.trim()) ?? 170.0;
    final weight = double.tryParse(_weightController.text.trim()) ?? 65.0;

    widget.onValidSubmit(
      fullName: _nameController.text.trim(),
      age: age,
      sex: _selectedSex,
      heightCm: height,
      weightKg: weight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Langkah 1 dari 4',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Data Fisik Pribadi',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Informasi ini digunakan langsung dalam rumus ilmiah Mifflin–St Jeor untuk menghitung laju metabolisme basal (BMR) Anda.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Nama Lengkap
          FitSyncTextField(
            controller: _nameController,
            label: 'Nama Lengkap',
            hint: 'Contoh: Budi Santoso',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 18),

          // Biological Sex Selection
          Text(
            'Jenis Kelamin Biologis',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Diperlukan karena perbedaan rata-rata massa otot dan pembakaran kalori alami pria & wanita.',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FitSyncCard(
                  isSelected: _selectedSex == BiologicalSex.male,
                  onTap: () => setState(() => _selectedSex = BiologicalSex.male),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male_rounded,
                        color: _selectedSex == BiologicalSex.male
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Laki-laki',
                        style: TextStyle(
                          color: _selectedSex == BiologicalSex.male
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FitSyncCard(
                  isSelected: _selectedSex == BiologicalSex.female,
                  onTap: () => setState(() => _selectedSex = BiologicalSex.female),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female_rounded,
                        color: _selectedSex == BiologicalSex.female
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Perempuan',
                        style: TextStyle(
                          color: _selectedSex == BiologicalSex.female
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Umur
          FitSyncTextField(
            controller: _ageController,
            label: 'Umur (Tahun)',
            hint: 'Contoh: 25',
            keyboardType: TextInputType.number,
            validator: (v) {
              final age = int.tryParse(v ?? '');
              if (age == null || age < 12 || age > 110) {
                return 'Masukkan umur yang valid (12 - 110 tahun)';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Row: Tinggi & Berat
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FitSyncTextField(
                  controller: _heightController,
                  label: 'Tinggi Badan (cm)',
                  hint: '172',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final h = double.tryParse(v ?? '');
                    if (h == null || h < 80 || h > 260) {
                      return 'Rentang 80-260 cm';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FitSyncTextField(
                  controller: _weightController,
                  label: 'Berat Badan (kg)',
                  hint: '68.5',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
        ],
      ),
    );
  }
}
