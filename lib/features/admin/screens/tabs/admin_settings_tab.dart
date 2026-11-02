import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../services/firebase_service.dart';
import '../../../../shared/widgets/fitsync_button.dart';
import '../../../../shared/widgets/fitsync_card.dart';
import '../../models/admin_role.dart';
import '../../providers/admin_provider.dart';

class AdminSettingsTab extends ConsumerWidget {
  const AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(currentAdminRoleProvider);
    final isFirebaseLive = FirebaseService.isInitialized;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pengaturan Hak Akses & Sistem',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Konfigurasi Role-Based Access Control (RBAC) dan status backend.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Role Switcher Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Mode Simulasi Hak Akses (RBAC)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Uji coba fitur dengan peran yang berbeda untuk memastikan batasan akses petugas gym dan administrator berfungsi.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                ),
                const SizedBox(height: 14),

                _buildRoleOption(
                  ref,
                  role: UserRole.admin,
                  title: 'Administrator Gym (Full Access)',
                  desc: 'Akses penuh: Member, Pembayaran, Turnstile, Paket & Latihan.',
                  isActive: currentRole == UserRole.admin,
                ),
                const SizedBox(height: 8),
                _buildRoleOption(
                  ref,
                  role: UserRole.staff,
                  title: 'Petugas Turnstile / Staff Gym',
                  desc: 'Akses terbatas: Hanya pemindaian QR turnstile dan riwayat check-in.',
                  isActive: currentRole == UserRole.staff,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Backend Connection Status Card
          FitSyncCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'STATUS KONEKSI BACKEND',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isFirebaseLive
                            ? AppColors.primaryContainer
                            : AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isFirebaseLive
                            ? 'CLOUDFIRESTORE LIVE'
                            : 'LOCAL FALLBACK VAULT',
                        style: TextStyle(
                          color: isFirebaseLive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isFirebaseLive
                      ? 'Terhubung langsung ke Cloud Firestore. Semua perubahan tersinkronisasi secara real-time.'
                      : 'Berjalan dalam mode sandbox lokal aman. Begitu file google-services.json dihubungkan, sistem otomatis sinkron ke server Firebase.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Security Audit Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_clock_outlined,
                        color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Audit Keamanan FitSync',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• Validasi QR Check-in: HMAC-SHA256 Token Rotation 60 Detik.\n• Proteksi Ganda: Pembayaran memerlukan persetujuan admin manual.\n• Pencegahan Double-Tap: Status terkunci selama proses eksekusi.\n• Aturan Firestore: firestore.rules dengan proteksi Role Claims.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Return to Member App Button
          FitSyncButton(
            text: 'Kembali ke Aplikasi Member (User)',
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.background, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRoleOption(
    WidgetRef ref, {
    required UserRole role,
    required String title,
    required String desc,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(currentAdminRoleProvider.notifier).state = role;
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surfaceHighlight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isActive
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
