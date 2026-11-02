import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/exercise.dart';
import '../../exercises/providers/exercise_provider.dart';

class ExercisePickerModal extends ConsumerStatefulWidget {
  final String? initialMuscle;
  final String title;

  const ExercisePickerModal({
    super.key,
    this.initialMuscle,
    this.title = 'Pilih Gerakan Pengganti',
  });

  static Future<Exercise?> show(
    BuildContext context, {
    String? initialMuscle,
    String title = 'Pilih Gerakan',
  }) {
    return showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.85,
        child: ExercisePickerModal(
          initialMuscle: initialMuscle,
          title: title,
        ),
      ),
    );
  }

  @override
  ConsumerState<ExercisePickerModal> createState() =>
      _ExercisePickerModalState();
}

class _ExercisePickerModalState extends ConsumerState<ExercisePickerModal> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late String _selectedMuscle;

  final List<String> _muscleFilters = [
    'Semua',
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

  @override
  void initState() {
    super.initState();
    _selectedMuscle = widget.initialMuscle != null &&
            _muscleFilters.contains(widget.initialMuscle)
        ? widget.initialMuscle!
        : 'Semua';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(exerciseRepositoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Cari nama gerakan atau alat...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Muscle Filter Chips
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _muscleFilters.length,
              itemBuilder: (ctx, i) {
                final muscle = _muscleFilters[i];
                final isSelected = muscle == _selectedMuscle;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    label: Text(
                      muscle,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceHighlight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: 0.8,
                      ),
                    ),
                    onSelected: (_) {
                      setState(() => _selectedMuscle = muscle);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Exercise List
          Expanded(
            child: FutureBuilder<List<Exercise>>(
              future: repo.getExercises(
                searchQuery: _searchQuery,
                targetMuscle: _selectedMuscle == 'Semua' ? null : _selectedMuscle,
                limit: 100,
              ),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                final exercises = snapshot.data ?? [];
                if (exercises.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada gerakan yang sesuai.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: exercises.length,
                  itemBuilder: (ctx, i) {
                    final ex = exercises[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context, ex),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHighlight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.fitness_center_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${ex.targetMuscle} • ${ex.equipment} • ${ex.recommendedSets} Set',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.secondary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
