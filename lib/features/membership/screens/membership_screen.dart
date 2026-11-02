import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/membership_plan.dart';
import '../../../shared/widgets/fitsync_button.dart';
import '../../../shared/widgets/fitsync_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/membership_provider.dart';
import '../widgets/dynamic_qr_view.dart';
import '../widgets/membership_card_view.dart';
import '../widgets/plan_purchase_modal.dart';
import '../widgets/turnstile_simulator_modal.dart';

class MembershipScreen extends ConsumerWidget {
  const MembershipScreen({super.key});

  void _showPurchaseModal(BuildContext context, MembershipPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanPurchaseModal(selectedPlan: plan),
    );
  }

  void _showTurnstileModal(BuildContext context, String qrPayload) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TurnstileSimulatorModal(qrPayload: qrPayload),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final membershipAsync = ref.watch(activeMembershipProvider);
    final qrState = ref.watch(dynamicQrProvider);
    final historyAsync = ref.watch(checkInHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: userProfileAsync.when(
          data: (profile) {
            if (profile == null) {
              return const Center(
                child: Text('Silakan login terlebih dahulu'),
              );
            }

            return membershipAsync.when(
              data: (membership) {
                final hasActive = membership != null && membership.isActive;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Title
                      Text(
                        'Membership Gym',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasActive
                            ? 'Akses fasilitas aktif & check-in mandiri dengan Kode QR.'
                            : 'Pilih paket akses gym fleksibel sesuai komitmen latihanmu.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (hasActive) ...[
                        // 1. Digital Membership Card
                        MembershipCardView(
                          membership: membership,
                          profile: profile,
                        ),
                        const SizedBox(height: 24),

                        // 2. Dynamic 60-Second Rotating QR Code
                        if (qrState != null) ...[
                          DynamicQrView(
                            qrState: qrState,
                            onRegenerate: () {
                              ref
                                  .read(dynamicQrProvider.notifier)
                                  .regenerateNow();
                            },
                          ),
                          const SizedBox(height: 16),

                          // 3. Turnstile Scanner Simulator Action
                          FitSyncButton(
                            text: 'Simulasi Scan Turnstile Pintu Gym',
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            variant: FitSyncButtonVariant.secondary,
                            onPressed: () => _showTurnstileModal(
                              context,
                              qrState.token.rawPayload,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 4. Riwayat Check-In Section
                        _buildCheckInHistory(context, historyAsync),
                        const SizedBox(height: 24),

                        // Manage / Extend / Cancel Option
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              _showManageOptions(context, ref, membership);
                            },
                            icon: const Icon(Icons.settings_outlined,
                                size: 16, color: AppColors.textMuted),
                            label: const Text(
                              'Kelola atau Ganti Paket Membership',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        // STATE B: Unregistered / Expired
                        if (membership != null && !membership.isActive) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    color: AppColors.error, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Membership ${membership.planName} Anda telah berakhir. Perbarui paket untuk mendapatkan kembali akses QR.',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Presentation of 2 Plans: Member 1 Bulan & Member Harian
                        _buildPlanCard(
                          context: context,
                          plan: MembershipPlan.getById('monthly-pass'),
                          isHighlighted: true,
                        ),
                        const SizedBox(height: 18),
                        _buildPlanCard(
                          context: context,
                          plan: MembershipPlan.getById('daily-pass'),
                          isHighlighted: false,
                        ),
                        const SizedBox(height: 24),

                        // Why Join FitSync Banner
                        _buildBenefitsBanner(context),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Text('Error membership: $err'),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(
            child: Text('Error profil: $err'),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required MembershipPlan plan,
    required bool isHighlighted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHighlighted
              ? AppColors.primary
              : AppColors.border,
          width: isHighlighted ? 1.8 : 1.0,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? AppColors.primaryContainer
                            : AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        plan.badge,
                        style: TextStyle(
                          color: isHighlighted
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Text(
                      plan.durationDays == 1 ? '1 HARI' : '30 HARI',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Name & Price
                Text(
                  plan.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      plan.formattedPrice,
                      style: TextStyle(
                        color: isHighlighted
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      plan.periodLabel,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  plan.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 14),

                // Feature List
                ...plan.features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isHighlighted
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.surfaceHighlight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: isHighlighted
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Select Plan Button
                FitSyncButton(
                  text: 'Pilih ${plan.name}',
                  icon: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: isHighlighted
                        ? AppColors.background
                        : AppColors.primary,
                  ),
                  variant: isHighlighted
                      ? FitSyncButtonVariant.primary
                      : FitSyncButtonVariant.secondary,
                  onPressed: () => _showPurchaseModal(context, plan),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInHistory(
    BuildContext context,
    AsyncValue<List<dynamic>> historyAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Kunjungan Gym',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            historyAsync.maybeWhen(
              data: (list) => Text(
                '${list.length} Kunjungan',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          data: (history) {
            if (history.isEmpty) {
              return FitSyncCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.history_toggle_off_rounded,
                        color: AppColors.textMuted, size: 28),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Belum ada riwayat check-in. Pindai QR di turnstile untuk mulai mencatat kunjungan gym.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

            return Column(
              children: history.take(5).map((record) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.sensor_door_rounded,
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
                                record.location,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateFormat.format(record.timestamp),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighlight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'GRANTED',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildBenefitsBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Fasilitas Lengkap FitSync Gym',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Semua member mendapatkan fasilitas higienis berstandar tinggi: Loker otomatis, shower air panas, water refill mineral, dan check-in mandiri 60 detik tanpa antrean manual di resepsionis.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showManageOptions(
    BuildContext context,
    WidgetRef ref,
    dynamic membership,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Kelola Membership',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded,
                    color: AppColors.primary),
                title: const Text(
                  'Ganti / Perpanjang Paket',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
                subtitle: const Text(
                  'Beralih antara Member Harian atau Member 1 Bulan',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showPurchaseModal(
                    context,
                    MembershipPlan.getById(
                      membership.planId == 'monthly-pass'
                          ? 'daily-pass'
                          : 'monthly-pass',
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.cancel_outlined,
                    color: AppColors.error),
                title: const Text(
                  'Batalkan / Reset Status Membership',
                  style: TextStyle(color: AppColors.error, fontSize: 14),
                ),
                subtitle: const Text(
                  'Menghapus akses QR dan status member aktif',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(membershipActionControllerProvider)
                      .cancelMembership();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
