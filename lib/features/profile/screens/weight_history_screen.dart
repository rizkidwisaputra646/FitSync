import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/fitness_enums.dart';
import '../../../models/user_profile.dart';
import '../../../models/weight_log_entry.dart';
import '../../../shared/widgets/fitsync_button.dart';
import '../../../shared/widgets/fitsync_card.dart';
import '../../../shared/widgets/fitsync_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class WeightHistoryScreen extends ConsumerStatefulWidget {
  const WeightHistoryScreen({super.key});

  @override
  ConsumerState<WeightHistoryScreen> createState() =>
      _WeightHistoryScreenState();
}

class _WeightHistoryScreenState extends ConsumerState<WeightHistoryScreen> {
  String _formatDate(DateTime dt) {
    try {
      return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return DateFormat('yyyy-MM-dd').format(dt);
    }
  }

  void _openAddWeightModal(BuildContext context, double currentWeight) {
    final weightController =
        TextEditingController(text: currentWeight.toStringAsFixed(1));
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Catat Berat Badan Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kalkulasi target kalori harian dan TDEE akan otomatis disesuaikan dengan berat badan terbaru Anda.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                FitSyncTextField(
                  controller: weightController,
                  label: 'Berat Badan Saat Ini (kg)',
                  hint: '68.5',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    final w = double.tryParse(val ?? '');
                    if (w == null || w < 25 || w > 350) {
                      return 'Masukkan angka valid (25 - 350 kg)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                FitSyncTextField(
                  controller: noteController,
                  label: 'Catatan (Opsional)',
                  hint: 'Contoh: Timbang pagi hari setelah bangun tidur',
                ),
                const SizedBox(height: 24),
                FitSyncButton(
                  text: 'Simpan & Perbarui Kalori',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final weight = double.parse(weightController.text.trim());
                    Navigator.pop(ctx);

                    await ref
                        .read(profileEditControllerProvider.notifier)
                        .logNewWeight(
                          newWeightKg: weight,
                          note: noteController.text.trim().isNotEmpty
                              ? noteController.text.trim()
                              : null,
                        );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Berat badan & target kalori berhasil diperbarui.'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final logsAsync = ref.watch(weightLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat & Progres Berat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: profileAsync.value != null
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Catat Berat',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: () => _openAddWeightModal(
                  context, profileAsync.value!.currentWeightKg),
            )
          : null,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          error: (err, _) => Center(
            child: Text('Gagal memuat profil: $err',
                style: const TextStyle(color: AppColors.error)),
          ),
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('Data profil tidak ditemukan.'));
            }

            return logsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              error: (err, _) => Center(
                child: Text('Gagal memuat log: $err',
                    style: const TextStyle(color: AppColors.error)),
              ),
              data: (logs) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 16, bottom: 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Ringkasan Progres Berat
                      _buildSummaryCard(profile, logs),
                      const SizedBox(height: 20),

                      // Chart Progres Berat Badan
                      Text(
                        'Grafik Perubahan Berat Badan',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FitSyncCard(
                        padding: const EdgeInsets.all(18),
                        child: logs.isEmpty
                            ? _buildEmptyState(
                                'Belum Ada Log Berat Badan',
                                'Tekan tombol "Catat Berat" di bawah untuk mulai memantau tren perkembangan tubuh Anda.',
                              )
                            : logs.length == 1
                                ? _buildSinglePointBanner(logs.first)
                                : _buildLineChart(logs),
                      ),
                      const SizedBox(height: 24),

                      // Daftar Riwayat Log
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Catatan Terakhir',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${logs.length} entri',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (logs.isEmpty)
                        FitSyncCard(
                          padding: const EdgeInsets.all(20),
                          child: _buildEmptyState(
                            'Riwayat Masih Kosong',
                            'Setiap kali Anda menimbang badan, catat di FitSync untuk menjaga akurasi perhitungan kalori harian.',
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: logs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final item = logs[i];
                            final prev = (i + 1 < logs.length) ? logs[i + 1] : null;
                            final delta = prev != null
                                ? item.weightKg - prev.weightKg
                                : 0.0;

                            return FitSyncCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceHighlight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.monitor_weight_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatDate(item.loggedAt),
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        if (item.note != null &&
                                            item.note!.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              item.note!,
                                              style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${item.weightKg.toStringAsFixed(1)} kg',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (prev != null)
                                        Text(
                                          delta > 0
                                              ? '+${delta.toStringAsFixed(1)} kg'
                                              : '${delta.toStringAsFixed(1)} kg',
                                          style: TextStyle(
                                            color: delta == 0
                                                ? AppColors.textMuted
                                                : (profile.fitnessGoal ==
                                                        FitnessGoal.weightLoss
                                                    ? (delta < 0
                                                        ? AppColors.success
                                                        : AppColors.error)
                                                    : (delta > 0
                                                        ? AppColors.success
                                                        : AppColors.error)),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(UserProfile profile, List<WeightLogEntry> logs) {
    final firstWeight = logs.isNotEmpty ? logs.last.weightKg : profile.currentWeightKg;
    final totalDelta = profile.currentWeightKg - firstWeight;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCol('Saat Ini', '${profile.currentWeightKg} kg'),
          Container(width: 1, height: 36, color: AppColors.divider),
          _buildSummaryCol(
            'Target',
            profile.targetWeightKg != null
                ? '${profile.targetWeightKg} kg'
                : 'Belum diisi',
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          _buildSummaryCol(
            'Perubahan Total',
            totalDelta == 0.0
                ? '0.0 kg'
                : totalDelta > 0
                    ? '+${totalDelta.toStringAsFixed(1)} kg'
                    : '${totalDelta.toStringAsFixed(1)} kg',
            color: totalDelta < 0 ? AppColors.success : AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCol(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSinglePointBanner(WeightLogEntry entry) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insights_rounded,
                color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              'Titik awal tercatat: ${entry.weightKg} kg',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tambahkan log penimbangan berikutnya untuk menampilkan garis tren progres.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<WeightLogEntry> logs) {
    // Reverse agar berurutan dari waktu lampau ke waktu terbaru untuk grafik
    final chronological = logs.reversed.toList();
    final spots = <FlSpot>[];

    double minY = chronological.first.weightKg;
    double maxY = chronological.first.weightKg;

    for (int i = 0; i < chronological.length; i++) {
      final w = chronological[i].weightKg;
      if (w < minY) minY = w;
      if (w > maxY) maxY = w;
      spots.add(FlSpot(i.toDouble(), w));
    }

    // Beri bantalan atas dan bawah
    minY = (minY - 2).clamp(0, 400).toDouble();
    maxY = maxY + 2;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.divider,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (val, _) {
                  return Text(
                    val.toStringAsFixed(0),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  if (idx >= 0 && idx < chronological.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        DateFormat('d/M').format(chronological[idx].loggedAt),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.background,
                  strokeWidth: 2.5,
                  strokeColor: AppColors.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.25),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Column(
      children: [
        const Icon(Icons.scale_rounded, color: AppColors.textMuted, size: 36),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
