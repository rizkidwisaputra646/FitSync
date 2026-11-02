import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/fitsync_button.dart';
import '../../../../shared/widgets/fitsync_card.dart';
import '../../../exercises/providers/exercise_provider.dart';
import '../../providers/admin_provider.dart';

class AdminExercisesTab extends ConsumerStatefulWidget {
  const AdminExercisesTab({super.key});

  @override
  ConsumerState<AdminExercisesTab> createState() => _AdminExercisesTabState();
}

class _AdminExercisesTabState extends ConsumerState<AdminExercisesTab> {
  String _searchQuery = '';
  bool _isImporting = false;

  Future<void> _handleBulkImport() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Import Massal ke Cloud Firestore',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        content: const Text(
          'Tindakan ini akan membaca dataset 320+ latihan lokal (lengkap dengan URL media Cloudflare R2) dan menyimpannya ke koleksi Firestore "exercises" secara batch.\n\nLanjutkan?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Mulai Import',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isImporting = true);

    try {
      final importedCount = await ref
          .read(adminActionControllerProvider)
          .bulkImportExercisesToFirestore();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceElevated,
            content: Text(
              'Berhasil mengimpor $importedCount gerakan ke Cloud Firestore.',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseListProvider);

    return Column(
      children: [
        // Top Bulk Import Action Card
        Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, top: 14, bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Sinkronisasi Dataset Latihan',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                    exercisesAsync.maybeWhen(
                      data: (list) => Text(
                        '${list.length} Gerakan',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Media GIF latihan di-host di Cloudflare R2 untuk efisiensi ukuran APK.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 12),
                FitSyncButton(
                  text: _isImporting
                      ? 'Mengimpor ke Firestore...'
                      : 'Import Massal 320+ Gerakan ke Firestore',
                  icon: const Icon(Icons.sync_rounded,
                      color: AppColors.background, size: 16),
                  isLoading: _isImporting,
                  height: 40,
                  onPressed: _isImporting ? null : _handleBulkImport,
                ),
              ],
            ),
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Cari nama gerakan atau alat gym...',
              hintStyle:
                  const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.primary, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),

        // Exercise list
        Expanded(
          child: exercisesAsync.when(
            data: (exercises) {
              final filtered = exercises.where((e) {
                if (_searchQuery.isEmpty) return true;
                return e.name.toLowerCase().contains(_searchQuery) ||
                    e.equipment.toLowerCase().contains(_searchQuery) ||
                    e.targetMuscle.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada gerakan ditemukan.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final ex = filtered[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FitSyncCard(
                      padding: const EdgeInsets.all(12),
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
                              size: 18,
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
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${ex.targetMuscle} • ${ex.equipment}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ex.difficulty.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (err, _) => Center(
              child: Text('Gagal memuat dataset: $err'),
            ),
          ),
        ),
      ],
    );
  }
}
