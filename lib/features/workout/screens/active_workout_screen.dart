import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../exercises/screens/exercise_detail_screen.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_picker_modal.dart';
import '../widgets/rest_timer_modal.dart';
import '../widgets/set_tracker_row.dart';
import 'workout_summary_screen.dart';

class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeWorkoutControllerProvider);
    final notifier = ref.read(activeWorkoutControllerProvider.notifier);
    final profile = ref.watch(currentUserProfileProvider).value;

    if (state.session == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(
          child: Text('Tidak ada sesi latihan yang sedang aktif.'),
        ),
      );
    }

    final session = state.session!;
    final currentEx = state.currentExercise;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _showCancelDialog(context);
        if (shouldExit == true) {
          notifier.cancelSession();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              final shouldExit = await _showCancelDialog(context);
              if (shouldExit == true) {
                notifier.cancelSession();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                state.formattedElapsedTime,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () => _handleFinish(context, ref, notifier, profile?.currentWeightKg ?? 70.0),
              child: const Text(
                'Selesai',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Exercise horizontal selector pills
            Container(
              height: 48,
              color: AppColors.surface,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: session.exercises.length,
                itemBuilder: (ctx, i) {
                  final ex = session.exercises[i];
                  final isSelected = i == state.currentExerciseIndex;
                  final allDone =
                      ex.sets.isNotEmpty && ex.sets.every((s) => s.isCompleted);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      onSelected: (_) => notifier.selectExercise(i),
                      showCheckmark: false,
                      avatar: allDone
                          ? const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppColors.primary,
                            )
                          : null,
                      label: Text(
                        '${i + 1}. ${ex.exerciseName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textOnPrimary
                              : (allDone
                                  ? AppColors.primary
                                  : AppColors.textSecondary),
                        ),
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceHighlight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : (allDone
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : AppColors.border),
                          width: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Active exercise detail & Set Tracker
            Expanded(
              child: currentEx == null
                  ? const Center(child: Text('Tidak ada gerakan'))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Exercise Name & Muscle Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentEx.exerciseName,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      currentEx.targetMuscle,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Demo Link Button
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ExerciseDetailScreen(
                                      exerciseId: currentEx.exerciseId,
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                side: const BorderSide(
                                    color: AppColors.border, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(
                                Icons.play_circle_outline_rounded,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                              label: const Text(
                                'Demo Gerakan',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Table Header
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Text(
                                  'SET',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  'BEBAN',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  'REPS',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              SizedBox(
                                width: 38,
                                child: Center(
                                  child: Icon(
                                    Icons.done_all_rounded,
                                    size: 16,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Sets list
                        ...currentEx.sets.asMap().entries.map((entry) {
                          final setIdx = entry.key;
                          final set = entry.value;

                          return SetTrackerRow(
                            key: ValueKey(
                                '${currentEx.exerciseId}_set_${set.setNumber}'),
                            set: set,
                            onToggleComplete: () {
                              notifier.toggleSetCompleted(
                                state.currentExerciseIndex,
                                setIdx,
                              );
                            },
                            onWeightChanged: (newWeight) {
                              notifier.updateSetActuals(
                                state.currentExerciseIndex,
                                setIdx,
                                weightKg: newWeight,
                              );
                            },
                            onRepsChanged: (newReps) {
                              notifier.updateSetActuals(
                                state.currentExerciseIndex,
                                setIdx,
                                reps: newReps,
                              );
                            },
                          );
                        }),

                        const SizedBox(height: 6),

                        // Add Set & Remove Exercise Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () => notifier.addSetToExercise(
                                  state.currentExerciseIndex),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Tambah Set'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                              ),
                            ),
                            if (session.exercises.length > 1)
                              TextButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: AppColors.surfaceElevated,
                                      title: const Text('Hapus Gerakan Ini?'),
                                      content: Text(
                                          'Hapus ${currentEx.exerciseName} dari sesi latihan saat ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColors.error,
                                          ),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    notifier.removeExercise(
                                        state.currentExerciseIndex);
                                  }
                                },
                                icon: const Icon(
                                    Icons.remove_circle_outline_rounded,
                                    size: 15),
                                label: const Text('Hapus Gerakan'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textMuted,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Add Extra Exercise to Live Session
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await ExercisePickerModal.show(
                              context,
                              title: 'Tambah Gerakan ke Sesi Ini',
                            );
                            if (picked != null) {
                              notifier.addExercise(
                                picked.id,
                                picked.name,
                                picked.targetMuscle,
                                setsCount: picked.recommendedSets,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${picked.name} ditambahkan ke sesi latihan.'),
                                    backgroundColor: AppColors.primaryContainer,
                                  ),
                                );
                              }
                            }
                          },
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
                          icon: const Icon(Icons.playlist_add_rounded,
                              size: 18, color: AppColors.primary),
                          label: const Text(
                            'Tambah Gerakan Baru ke Sesi Ini',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Next / Prev Exercise Navigation
                        Row(
                          children: [
                            if (state.currentExerciseIndex > 0)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => notifier.prevExercise(),
                                  icon: const Icon(
                                      Icons.arrow_back_ios_rounded,
                                      size: 14),
                                  label: const Text('Sebelumnya'),
                                ),
                              ),
                            if (state.currentExerciseIndex > 0 &&
                                state.currentExerciseIndex <
                                    session.exercises.length - 1)
                              const SizedBox(width: 12),
                            if (state.currentExerciseIndex <
                                session.exercises.length - 1)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => notifier.nextExercise(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.surfaceHighlight,
                                    foregroundColor: AppColors.textPrimary,
                                  ),
                                  icon: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14),
                                  label: const Text('Gerakan Berikutnya'),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Big Finish Button
                        ElevatedButton(
                          onPressed: () => _handleFinish(
                            context,
                            ref,
                            notifier,
                            profile?.currentWeightKg ?? 70.0,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Selesaikan Latihan Sekarang',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
          ],
        ),
        bottomSheet: state.isResting
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: RestTimerBar(
                  secondsRemaining: state.restSecondsRemaining,
                  onAdd30s: () => notifier.addRestSeconds(30),
                  onSkip: () => notifier.skipRestTimer(),
                ),
              )
            : null,
      ),
    );
  }

  Future<void> _handleFinish(
    BuildContext context,
    WidgetRef ref,
    ActiveWorkoutNotifier notifier,
    double userWeightKg,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Konfirmasi Selesai'),
        content: const Text(
          'Simpan seluruh repetisi, beban aktual, dan durasi ke riwayat latihan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Lanjut Latihan'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Ya, Simpan'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final savedSession = await notifier.finishSession(
        userWeightKg: userWeightKg,
      );
      if (savedSession != null && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutSummaryScreen(session: savedSession),
          ),
        );
      }
    }
  }

  Future<bool?> _showCancelDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Batalkan Sesi Latihan?'),
        content: const Text(
          'Seluruh catatan set dan waktu sesi ini tidak akan disimpan ke riwayat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali Latihan'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }
}
