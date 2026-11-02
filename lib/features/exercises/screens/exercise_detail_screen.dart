import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/fitsync_button.dart';
import '../providers/exercise_provider.dart';
import 'edit_custom_exercise_screen.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final String exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(exerciseDetailProvider(exerciseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Gerakan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          detailAsync.maybeWhen(
            data: (exercise) {
              if (exercise == null) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Edit Gerakan',
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCustomExerciseScreen(
                        initialExercise: exercise,
                      ),
                    ),
                  );
                },
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (err, _) => Center(
          child: Text(
            'Gagal memuat detail gerakan: $err',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        data: (exercise) {
          if (exercise == null) {
            return const Center(child: Text('Gerakan tidak ditemukan.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(
                left: 20, right: 20, top: 12, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // GIF Demonstrasi (Cloudflare R2 Media)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 240,
                    color: AppColors.surfaceElevated,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: exercise.gifUrl,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                          errorWidget: (ctx, url, err) => Container(
                            color: AppColors.surfaceHighlight,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.fitness_center_rounded,
                                  color: AppColors.primary,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Media Demonstrasi Cloudflare R2',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Badge R2 Stream
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.background.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.cloud_done_rounded,
                                    color: AppColors.primary, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Cloudflare R2',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title & Muscle Tags
                Text(
                  exercise.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                // Row of Chips: Target Muscle, Equipment, Difficulty
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag('Target: ${exercise.targetMuscle}',
                        AppColors.primaryContainer, AppColors.primary),
                    _buildTag('Alat: ${exercise.equipment}',
                        AppColors.surfaceHighlight, AppColors.textPrimary),
                    _buildTag('Level: ${exercise.difficulty}',
                        AppColors.surfaceHighlight, AppColors.secondary),
                  ],
                ),
                const SizedBox(height: 16),

                // Otot Pendukung jika ada
                if (exercise.secondaryMuscles.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.accessibility_new_rounded,
                          size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Otot Pendukung: ${exercise.secondaryMuscles.join(', ')}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Rekomendasi Set & Reps Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricCol('Rekomendasi Set',
                          '${exercise.recommendedSets} Set'),
                      Container(width: 1, height: 32, color: AppColors.divider),
                      _buildMetricCol(
                          'Rekomendasi Repetisi', exercise.recommendedReps),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Instruksi Langkah demi Langkah
                Text(
                  'Instruksi Pelaksanaan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...exercise.instructions.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final text = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$idx',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            text,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Tips Teknik & Keselamatan
                if (exercise.tips.isNotEmpty) ...[
                  Text(
                    'Tips Teknik & Keselamatan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...exercise.tips.map((tip) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.accentMuted.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],

                // Tombol Aksi: Tambah ke Workout / Mulai Latihan
                Row(
                  children: [
                    Expanded(
                      child: FitSyncButton(
                        text: 'Mulai Latihan',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Memulai sesi latihan: ${exercise.name} (Active Workout akan aktif di Tahap 4).'),
                              backgroundColor: AppColors.primaryContainer,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color textClr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textClr,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
