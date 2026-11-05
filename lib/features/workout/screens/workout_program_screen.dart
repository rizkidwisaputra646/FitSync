import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/user_profile.dart';
import '../../../models/workout_program.dart';
import '../../../models/workout_session.dart';
import '../../../shared/widgets/fitsync_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../exercises/providers/exercise_provider.dart';
import '../../exercises/screens/exercise_detail_screen.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_picker_modal.dart';
import 'active_workout_screen.dart';

class WorkoutProgramScreen extends ConsumerStatefulWidget {
  const WorkoutProgramScreen({super.key});

  @override
  ConsumerState<WorkoutProgramScreen> createState() =>
      _WorkoutProgramScreenState();
}

class _WorkoutProgramScreenState extends ConsumerState<WorkoutProgramScreen> {
  int _selectedDayNumber = 1;

  Future<void> _swapExercise(
    UserProfile profile,
    WorkoutProgram program,
    ProgramDay day,
    int exerciseIndex,
  ) async {
    final current = day.exercises[exerciseIndex];
    final picked = await ExercisePickerModal.show(
      context,
      initialMuscle: current.targetMuscle,
      title: 'Tukar Gerakan: ${current.exerciseName}',
    );
    if (picked == null || !mounted) return;

    final updatedExercises = [...day.exercises];
    updatedExercises[exerciseIndex] = ProgramExerciseItem(
      exerciseId: picked.id,
      exerciseName: picked.name,
      targetMuscle: picked.targetMuscle,
      targetSets: current.targetSets,
      targetReps: current.targetReps,
      restSeconds: current.restSeconds,
      notes: current.notes,
    );

    final updatedDay = ProgramDay(
      dayNumber: day.dayNumber,
      title: day.title,
      isRestDay: day.isRestDay,
      targetMuscles: day.targetMuscles,
      description: day.description,
      exercises: updatedExercises,
    );

    final repo = ref.read(workoutRepositoryProvider);
    await repo.saveCustomizedDay(profile.uid, program.id, updatedDay);
    ref.invalidate(workoutProgramProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gerakan berhasil ditukar ke ${picked.name}'),
          backgroundColor: AppColors.primaryContainer,
        ),
      );
    }
  }

  Future<void> _addExercise(
    UserProfile profile,
    WorkoutProgram program,
    ProgramDay day,
  ) async {
    final picked = await ExercisePickerModal.show(
      context,
      title: 'Tambah Gerakan ke Hari ${day.dayNumber}',
    );
    if (picked == null || !mounted) return;

    final updatedExercises = [
      ...day.exercises,
      ProgramExerciseItem(
        exerciseId: picked.id,
        exerciseName: picked.name,
        targetMuscle: picked.targetMuscle,
        targetSets: picked.recommendedSets,
        targetReps: picked.recommendedReps,
        restSeconds: 60,
      ),
    ];

    final updatedDay = ProgramDay(
      dayNumber: day.dayNumber,
      title: day.title,
      isRestDay: day.isRestDay,
      targetMuscles: day.targetMuscles,
      description: day.description,
      exercises: updatedExercises,
    );

    final repo = ref.read(workoutRepositoryProvider);
    await repo.saveCustomizedDay(profile.uid, program.id, updatedDay);
    ref.invalidate(workoutProgramProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${picked.name} ditambahkan ke jadwal Hari ${day.dayNumber}'),
          backgroundColor: AppColors.primaryContainer,
        ),
      );
    }
  }

  Future<void> _removeExercise(
    UserProfile profile,
    WorkoutProgram program,
    ProgramDay day,
    int exerciseIndex,
  ) async {
    if (day.exercises.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal harus ada 1 gerakan dalam jadwal latihan.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final removedName = day.exercises[exerciseIndex].exerciseName;
    final updatedExercises = [...day.exercises]..removeAt(exerciseIndex);

    final updatedDay = ProgramDay(
      dayNumber: day.dayNumber,
      title: day.title,
      isRestDay: day.isRestDay,
      targetMuscles: day.targetMuscles,
      description: day.description,
      exercises: updatedExercises,
    );

    final repo = ref.read(workoutRepositoryProvider);
    await repo.saveCustomizedDay(profile.uid, program.id, updatedDay);
    ref.invalidate(workoutProgramProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$removedName dihapus dari jadwal Hari ${day.dayNumber}'),
          backgroundColor: AppColors.surfaceHighlight,
        ),
      );
    }
  }

  Future<void> _resetDay(
    UserProfile profile,
    WorkoutProgram program,
    int dayNumber,
  ) async {
    final repo = ref.read(workoutRepositoryProvider);
    await repo.resetDayToDefault(profile.uid, program.id, dayNumber);
    ref.invalidate(workoutProgramProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jadwal Hari $dayNumber dikembalikan ke setelan awal.'),
          backgroundColor: AppColors.primaryContainer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(currentUserProfileProvider).value;
    final programAsync = ref.watch(workoutProgramProvider);
    final historyAsync = ref.watch(workoutHistoryProvider);
    final completedDays = ref.watch(completedDaysProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: programAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (err, _) => Center(
          child: Text(
            'Gagal memuat program: $err',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        data: (program) {
          if (program == null || profile == null) {
            return const Center(child: Text('Program tidak ditemukan.'));
          }

          final selectedDay = program.getDay(_selectedDayNumber);
          final completedCount = completedDays.length;
          final progressPercent = (completedCount / 30.0).clamp(0.0, 1.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Program Latihan',
                      style: theme.textTheme.headlineLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        profile.experienceLevel.title,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  program.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                // 30-Day Progress Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B2620), Color(0xFF121B16)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'PROGRES PROGRAM 30 HARI',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            '$completedCount dari 30 Hari',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 8,
                          backgroundColor: AppColors.surfaceHighlight,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progressPercent * 100).round()}% Selesai • ${30 - completedCount} Hari Tersisa',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Horizontal Day Navigator (Days 1 to 30)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Hari Latihan',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Hari $_selectedDayNumber',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 72,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 30,
                    itemBuilder: (ctx, i) {
                      final dayNum = i + 1;
                      final isSelected = dayNum == _selectedDayNumber;
                      final isDone = completedDays.contains(dayNum);
                      final isRest = program.getDay(dayNum).isRestDay;

                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDayNumber = dayNum),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 54,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryContainer
                                : (isDone
                                    ? const Color(0xFF19281E)
                                    : AppColors.surfaceElevated),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDone
                                      ? AppColors.primary.withValues(alpha: 0.6)
                                      : AppColors.border),
                              width: isSelected ? 1.8 : 0.8,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'HARI',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$dayNum',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (isDone)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 13,
                                  color: AppColors.primary,
                                )
                              else if (isRest)
                                const Icon(
                                  Icons.bedtime_outlined,
                                  size: 13,
                                  color: AppColors.secondary,
                                )
                              else
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.textMuted,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Selected Day Detail Card
                FitSyncCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedDay.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (selectedDay.isRestDay)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHighlight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Rest Day',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedDay.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Planned Exercises List
                      if (!selectedDay.isRestDay) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gerakan Latihan (${selectedDay.exercises.length} Gerakan):',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _resetDay(profile, program, selectedDay.dayNumber),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 13, color: AppColors.textMuted),
                              label: const Text(
                                'Reset Hari',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...selectedDay.exercises.asMap().entries.map((entry) {
                          final idx = entry.key + 1;
                          final exIdx = entry.key;
                          final ex = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _ProgramExerciseThumbnail(
                                    exerciseId: ex.exerciseId,
                                    index: idx,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ExerciseDetailScreen(
                                              exerciseId: ex.exerciseId,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex.exerciseName,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            '${ex.targetSets} Set • ${ex.targetReps} • Istirahat ${ex.restSeconds}s',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Swap Exercise Button
                                  IconButton(
                                    tooltip: 'Tukar Gerakan Ini',
                                    icon: const Icon(
                                      Icons.swap_horiz_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () => _swapExercise(
                                      profile,
                                      program,
                                      selectedDay,
                                      exIdx,
                                    ),
                                  ),
                                  // Delete Exercise Button
                                  IconButton(
                                    tooltip: 'Hapus dari Hari Ini',
                                    icon: const Icon(
                                      Icons.remove_circle_outline_rounded,
                                      size: 17,
                                      color: AppColors.textMuted,
                                    ),
                                    onPressed: () => _removeExercise(
                                      profile,
                                      program,
                                      selectedDay,
                                      exIdx,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),

                        // Add Exercise to Day Button
                        OutlinedButton.icon(
                          onPressed: () => _addExercise(profile, program, selectedDay),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                          label: const Text(
                            'Tambah Gerakan ke Hari Ini',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action Button
                        ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(activeWorkoutControllerProvider.notifier)
                                .startSession(
                                  profile: profile,
                                  program: program,
                                  day: selectedDay,
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ActiveWorkoutScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 22),
                          label: Text(
                            'Mulai Latihan Hari ${selectedDay.dayNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.bedtime_outlined,
                                color: AppColors.secondary,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Hari ini difokuskan untuk regenerasi serat otot dan tidur berkualitas. Hindari beban berat.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Workout History Section
                Text(
                  'Riwayat Latihan Terkini',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                historyAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => FitSyncCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.fitness_center_rounded,
                          size: 36,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Belum Ada Sesi Latihan Selesai',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mulai Hari 1 dari program Anda di atas untuk merekam repetisi dan beban aktual.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  data: (history) {
                    if (history.isEmpty) {
                      return FitSyncCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.fitness_center_rounded,
                              size: 36,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Belum Ada Sesi Latihan Selesai',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mulai Hari 1 dari program Anda di atas untuk merekam repetisi dan beban aktual.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: history.take(5).map((session) {
                        return _buildHistoryCard(context, session);
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, WorkoutSession session) {
    String formattedDate = '';
    try {
      formattedDate =
          DateFormat('EEEE, d MMM yyyy • HH:mm', 'id_ID').format(session.startTime);
    } catch (_) {
      formattedDate = session.startTime.toIso8601String().split('T').first;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FitSyncCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    session.dayTitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Hari ${session.dayNumber}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHistoryMetric(
                  'Volume Beban',
                  '${session.totalVolumeKg.round()} kg',
                  AppColors.primary,
                ),
                _buildHistoryMetric(
                  'Durasi',
                  session.formattedDuration,
                  AppColors.secondary,
                ),
                _buildHistoryMetric(
                  'Set Selesai',
                  '${session.totalSetsCompleted} Set',
                  AppColors.textPrimary,
                ),
                _buildHistoryMetric(
                  'Kalori',
                  '~${session.caloriesBurned} kkal',
                  AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProgramExerciseThumbnail extends ConsumerWidget {
  final String exerciseId;
  final int index;

  const _ProgramExerciseThumbnail({
    required this.exerciseId,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(exerciseDetailProvider(exerciseId));

    return detailAsync.maybeWhen(
      data: (exercise) {
        final imgUrl = exercise?.thumbnailUrl ?? exercise?.gifUrl;
        if (imgUrl == null || imgUrl.isEmpty) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 40,
            height: 40,
            color: Colors.white,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CachedNetworkImage(
                    imageUrl: imgUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Container(
                      color: AppColors.surfaceHighlight,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceHighlight,
                      child: const Icon(Icons.fitness_center_rounded,
                          size: 16, color: AppColors.textMuted),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$index',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
