import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/exercise.dart';
import '../providers/exercise_provider.dart';

class EditCustomExerciseScreen extends ConsumerStatefulWidget {
  final Exercise? initialExercise;

  const EditCustomExerciseScreen({super.key, this.initialExercise});

  @override
  ConsumerState<EditCustomExerciseScreen> createState() =>
      _EditCustomExerciseScreenState();
}

class _EditCustomExerciseScreenState
    extends ConsumerState<EditCustomExerciseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _repsController;
  late TextEditingController _setsController;
  late TextEditingController _instructionsController;
  late TextEditingController _tipsController;
  late TextEditingController _gifUrlController;

  late String _selectedMuscle;
  late String _selectedEquipment;
  late String _selectedDifficulty;

  static const _muscleOptions = [
    'Chest',
    'Back',
    'Shoulder',
    'Biceps',
    'Triceps',
    'Legs',
    'Glutes',
    'Abs & Core',
    'Full Body',
    'Cardio',
  ];

  static const _equipmentOptions = [
    'Barbell',
    'Dumbbell',
    'Cable Machine',
    'Smith Machine',
    'Bench',
    'Leg Press Machine',
    'Leg Curl Machine',
    'Lat Pulldown Machine',
    'Seated Row Machine',
    'Chest Press Machine',
    'Resistance Machine',
    'Kettlebell',
    'Bodyweight',
  ];

  static const _difficultyOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();
    final ex = widget.initialExercise;
    _nameController = TextEditingController(text: ex?.name ?? '');
    _repsController =
        TextEditingController(text: ex?.recommendedReps ?? '10-12 Reps');
    _setsController =
        TextEditingController(text: '${ex?.recommendedSets ?? 3}');
    _instructionsController =
        TextEditingController(text: ex?.instructions.join('\n') ?? '');
    _tipsController = TextEditingController(text: ex?.tips.join('\n') ?? '');
    _gifUrlController = TextEditingController(text: ex?.gifUrl ?? '');

    _selectedMuscle = ex != null && _muscleOptions.contains(ex.targetMuscle)
        ? ex.targetMuscle
        : _muscleOptions.first;

    _selectedEquipment =
        ex != null && _equipmentOptions.contains(ex.equipment)
            ? ex.equipment
            : _equipmentOptions.first;

    _selectedDifficulty =
        ex != null && _difficultyOptions.contains(ex.difficulty)
            ? ex.difficulty
            : 'Intermediate';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    _instructionsController.dispose();
    _tipsController.dispose();
    _gifUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.initialExercise != null;
    final id = isEdit
        ? widget.initialExercise!.id
        : 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final instructions = _instructionsController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final tips = _tipsController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final exercise = Exercise(
      id: id,
      name: _nameController.text.trim(),
      targetMuscle: _selectedMuscle,
      equipment: _selectedEquipment,
      difficulty: _selectedDifficulty,
      recommendedSets: int.tryParse(_setsController.text.trim()) ?? 3,
      recommendedReps: _repsController.text.trim(),
      instructions: instructions.isNotEmpty
          ? instructions
          : ['Lakukan gerakan dengan teknik dan postur yang stabil.'],
      tips: tips.isNotEmpty
          ? tips
          : ['Jaga pernapasan dan kendali beban penuh sepanjang gerak.'],
      gifUrl: _gifUrlController.text.trim(),
      isActive: true,
      isCustom: true,
    );

    final repo = ref.read(exerciseRepositoryProvider);
    await repo.saveCustomExercise(exercise);

    ref.invalidate(exerciseListProvider);
    if (isEdit) {
      ref.invalidate(exerciseDetailProvider(id));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Gerakan berhasil diperbarui!'
                : 'Gerakan kustom baru berhasil ditambahkan!',
          ),
          backgroundColor: AppColors.primaryContainer,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialExercise != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Gerakan Latihan' : 'Buat Gerakan Baru'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama Gerakan
              const Text(
                'NAMA GERAKAN',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Incline Dumbbell Bench Press',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama gerakan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Otot Target
              const Text(
                'OTOT TARGET UTAMA',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedMuscle,
                isExpanded: true,
                dropdownColor: AppColors.surfaceElevated,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                items: _muscleOptions
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            m,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedMuscle = val);
                  }
                },
              ),
              const SizedBox(height: 18),

              // Alat Gym
              const Text(
                'ALAT GYM YANG DIGUNAKAN',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedEquipment,
                isExpanded: true,
                dropdownColor: AppColors.surfaceElevated,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                items: _equipmentOptions
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedEquipment = val);
                  }
                },
              ),
              const SizedBox(height: 18),

              // Kesulitan, Target Set, Target Reps Row
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LEVEL KESULITAN',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedDifficulty,
                          isExpanded: true,
                          dropdownColor: AppColors.surfaceElevated,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 14),
                          ),
                          items: _difficultyOptions
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(
                                      d,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedDifficulty = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SET',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _setsController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TARGET REPS',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _repsController,
                          decoration: const InputDecoration(
                            hintText: '8-12 Reps',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Panduan Instruksi (1 per baris)
              const Text(
                'INSTRUKSI LANGKAH (Satu langkah per baris)',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _instructionsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      '1. Posisikan tubuh pada bangku...\n2. Turunkan dumbel terkontrol 2 detik...\n3. Dorong kembali ke atas.',
                ),
              ),
              const SizedBox(height: 18),

              // Tips Keselamatan
              const Text(
                'TIPS KEAMANAN / FORM (Satu tips per baris)',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tipsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText:
                      'Jaga siku tidak terlalu melebar ke samping untuk melindungi bahu.',
                ),
              ),
              const SizedBox(height: 18),

              // Link GIF / Media URL (Opsional)
              const Text(
                'URL DEMO GIF / GAMBAR (Opsional)',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _gifUrlController,
                decoration: const InputDecoration(
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 28),

              // Save Button
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEdit ? 'Perbarui Gerakan' : 'Simpan Gerakan Baru',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
