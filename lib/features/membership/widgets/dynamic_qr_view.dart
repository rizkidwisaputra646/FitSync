import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/qr_checkin_token.dart';
import '../providers/membership_provider.dart';

class DynamicQrView extends StatelessWidget {
  final DynamicQrState qrState;
  final VoidCallback onRegenerate;

  const DynamicQrView({
    super.key,
    required this.qrState,
    required this.onRegenerate,
  });

  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    IconData badgeIcon;
    String label;

    switch (qrState.syncStatus) {
      case QrSyncStatus.active:
        badgeColor = AppColors.success;
        badgeIcon = Icons.sensors_rounded;
        label = qrState.secondsRemaining < 10
            ? 'Kedaluwarsa sebentar lagi'
            : 'QR Aktif & Siap Dipindai';
        break;
      case QrSyncStatus.refreshing:
        badgeColor = AppColors.warning;
        badgeIcon = Icons.sync_rounded;
        label = 'Memperbarui token ke server...';
        break;
      case QrSyncStatus.used:
        badgeColor = AppColors.primary;
        badgeIcon = Icons.check_circle_rounded;
        label = 'Check-in Berhasil! Memutar QR...';
        break;
      case QrSyncStatus.expired:
        badgeColor = AppColors.error;
        badgeIcon = Icons.timer_off_rounded;
        label = 'Token kedaluwarsa. Memperbarui...';
        break;
      case QrSyncStatus.error:
        badgeColor = AppColors.error;
        badgeIcon = Icons.cloud_off_rounded;
        label = 'Gagal sinkronisasi (Mode offline)';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: badgeColor, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seconds = qrState.secondsRemaining;
    final progress = qrState.progress;

    // Color shift as token gets close to expiring (< 10 seconds warning)
    final timerColor = seconds < 10 ? AppColors.warning : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        children: [
          // Section Title & Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'CHECK-IN GATE GYM',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Arahkan kode QR ke scanner turnstile saat memasuki area gym',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),

          // Realtime Status Badge
          _buildStatusBadge(context),
          const SizedBox(height: 18),

          // QR Code Frame with Neon Glow & Used Feedback
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (qrState.syncStatus == QrSyncStatus.used
                              ? AppColors.success
                              : AppColors.primary)
                          .withValues(alpha: 0.18),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrState.token.rawPayload,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0C1210),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF0C1210),
                  ),
                ),
              ),
              if (qrState.syncStatus == QrSyncStatus.used)
                Container(
                  width: 232,
                  height: 232,
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.background,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Akses Diberikan!',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Selamat berlatih',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // 60-Second Rotating Timer Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 2.5,
                            backgroundColor: AppColors.surfaceHighlight,
                            color: timerColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Kode berganti otomatis dalam:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${seconds}s',
                      style: GoogleFonts.inter(
                        color: timerColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppColors.surfaceHighlight,
                    valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Anti-Fraud & Manual Refresh Button
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 15,
                      color: AppColors.accentMuted,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Anti-screenshot: Sinkronisasi Realtime Firebase',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onRegenerate,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Perbarui',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
