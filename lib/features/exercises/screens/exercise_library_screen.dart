import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/fitsync_card.dart';
import '../../../shared/widgets/fitsync_text_field.dart';
import '../providers/exercise_provider.dart';
import '../widgets/exercise_card.dart';
import 'edit_custom_exercise_screen.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  final _searchController = TextEditingController();

  final List<String> _muscleChips = [
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterModal(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final filter = ref.watch(exerciseFilterProvider);
            final filterNotifier = ref.read(exerciseFilterProvider.notifier);
            final equipsAsync = ref.watch(equipmentsProvider);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Katalog Latihan',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          filterNotifier.resetFilters();
                          _searchController.clear();
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Kesulitan
                  const Text(
                    'Tingkat Kesulitan',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Semua', 'Beginner', 'Intermediate', 'Advanced']
                        .map((diff) {
                      final isSelected = filter.selectedDifficulty == diff;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: FitSyncCard(
                            isSelected: isSelected,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            onTap: () {
                              filterNotifier.setDifficulty(diff);
                            },
                            child: Center(
                              child: Text(
                                diff,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Peralatan Gym
                  const Text(
                    'Peralatan Gym',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  equipsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (equips) {
                      final topEquips = equips.take(5).toList();
                      return Row(
                        children: topEquips.map((eq) {
                          final isSelected = filter.selectedEquipment == eq;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: FitSyncCard(
                                isSelected: isSelected,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                onTap: () => filterNotifier.setEquipment(eq),
                                child: Center(
                                  child: Text(
                                    eq,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Urutkan (Sorting)
                  const Text(
                    'Urutkan Alfabet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FitSyncCard(
                          isSelected: filter.sortBy == 'name_asc',
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onTap: () => filterNotifier.setSortBy('name_asc'),
                          child: const Center(
                            child: Text(
                              'A - Z',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FitSyncCard(
                          isSelected: filter.sortBy == 'name_desc',
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onTap: () => filterNotifier.setSortBy('name_desc'),
                          child: const Center(
                            child: Text(
                              'Z - A',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Terapkan Filter'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = ref.watch(exerciseFilterProvider);
    final filterNotifier = ref.read(exerciseFilterProvider.notifier);
    final exerciseListAsync = ref.watch(exerciseListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Search & Filter Bar
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exercise Library',
                            style: theme.textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '300+ Gerakan Gym dengan Demonstrasi R2',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Buat Gerakan Baru',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                            ),
                            icon: const Icon(Icons.add_rounded,
                                color: AppColors.primary),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const EditCustomExerciseScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Filter Latihan',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceHighlight,
                            ),
                            icon: const Icon(Icons.tune_rounded,
                                color: AppColors.primary),
                            onPressed: () => _openFilterModal(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Text Field
                  FitSyncTextField(
                    controller: _searchController,
                    label: '',
                    hint: 'Cari nama gerakan, otot, atau alat gym...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              filterNotifier.setSearchQuery('');
                            },
                          )
                        : null,
                    onChanged: (val) {
                      filterNotifier.setSearchQuery(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Horizontal Muscle Category Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _muscleChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final muscle = _muscleChips[i];
                  final isSelected = filter.selectedMuscle == muscle;

                  return GestureDetector(
                    onTap: () => filterNotifier.setMuscle(muscle),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          muscle,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Grid / List Gerakan
            Expanded(
              child: exerciseListAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.error, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal memuat katalog: $err',
                          style: const TextStyle(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                data: (exercises) {
                  if (exercises.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Tidak Ada Gerakan yang Cocok',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Coba ubah kata kunci pencarian atau sesuaikan kategori otot dan filter alat.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            OutlinedButton(
                              onPressed: () {
                                _searchController.clear();
                                filterNotifier.resetFilters();
                              },
                              child: const Text('Reset Semua Filter'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 30, top: 4),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: exercises.length,
                    itemBuilder: (ctx, i) {
                      return ExerciseCard(exercise: exercises[i]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
