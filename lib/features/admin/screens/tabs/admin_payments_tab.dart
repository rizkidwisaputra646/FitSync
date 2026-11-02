import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/fitsync_button.dart';
import '../../../../shared/widgets/fitsync_card.dart';
import '../../models/payment_transaction.dart';
import '../../providers/admin_provider.dart';

class AdminPaymentsTab extends ConsumerStatefulWidget {
  const AdminPaymentsTab({super.key});

  @override
  ConsumerState<AdminPaymentsTab> createState() => _AdminPaymentsTabState();
}

class _AdminPaymentsTabState extends ConsumerState<AdminPaymentsTab> {
  final Set<String> _processingIds = {};

  Future<void> _handleApprove(PaymentTransaction payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Konfirmasi Persetujuan Pembayaran',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        content: Text(
          'Setujui pembayaran ${payment.formattedAmount} untuk paket ${payment.planName} atas nama ${payment.userName}?\n\nMembership akan langsung diaktifkan.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
            child: const Text('Ya, Setujui',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _processingIds.add(payment.id));

    try {
      await ref
          .read(adminActionControllerProvider)
          .approvePayment(payment.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceElevated,
            content: Text(
              'Pembayaran ${payment.userName} (${payment.planName}) berhasil disetujui.',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processingIds.remove(payment.id));
    }
  }

  Future<void> _handleReject(PaymentTransaction payment) async {
    final reasonController = TextEditingController();

    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Tolak Pembayaran',
          style: TextStyle(color: AppColors.error, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan alasan penolakan pembayaran ${payment.userName}:',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Misal: Bukti transfer tidak valid atau nominal kurang',
                hintStyle:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(ctx, reasonController.text.trim());
            },
            child: const Text('Tolak Pembayaran',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    setState(() => _processingIds.add(payment.id));

    try {
      await ref
          .read(adminActionControllerProvider)
          .rejectPayment(payment.id, result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceElevated,
            content: Text(
              'Pembayaran ${payment.userName} telah ditolak.',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processingIds.remove(payment.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(adminPaymentsListProvider);
    final currentFilter = ref.watch(pendingPaymentsFilterProvider);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Column(
      children: [
        // Filter Tabs (Pending, Approved, Rejected, All)
        Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, top: 14, bottom: 8),
          child: Row(
            children: [
              _buildTabButton('pending', 'Menunggu (Pending)', currentFilter),
              const SizedBox(width: 8),
              _buildTabButton('approved', 'Disetujui', currentFilter),
              const SizedBox(width: 8),
              _buildTabButton('rejected', 'Ditolak', currentFilter),
            ],
          ),
        ),

        // Payments List
        Expanded(
          child: paymentsAsync.when(
            data: (payments) {
              if (payments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          color: AppColors.primary, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        currentFilter == 'pending'
                            ? 'Tidak ada pembayaran yang menunggu verifikasi.'
                            : 'Belum ada data pembayaran pada kategori ini.',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final p = payments[index];
                  final isProcessing = _processingIds.contains(p.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FitSyncCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Name & Amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.userName,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  Text(
                                    '${p.memberCode} • ${p.userEmail}',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                p.formattedAmount,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),

                          // Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Paket: ${p.planName}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                dateFormat.format(p.createdAt),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Metode: ${p.paymentMethod}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),

                          if (p.rejectionReason != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Alasan ditolak: ${p.rejectionReason}',
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],

                          // Action Buttons (Only for Pending)
                          if (p.status == PaymentStatus.pending) ...[
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: FitSyncButton(
                                    text: 'Setujui',
                                    icon: const Icon(Icons.check_rounded,
                                        color: AppColors.background, size: 16),
                                    isLoading: isProcessing,
                                    height: 42,
                                    onPressed: isProcessing
                                        ? null
                                        : () => _handleApprove(p),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FitSyncButton(
                                    text: 'Tolak',
                                    icon: const Icon(Icons.close_rounded,
                                        color: AppColors.error, size: 16),
                                    variant: FitSyncButtonVariant.secondary,
                                    isLoading: isProcessing,
                                    height: 42,
                                    onPressed: isProcessing
                                        ? null
                                        : () => _handleReject(p),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
              child: Text('Gagal memuat pembayaran: $err'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String? value, String label, String? current) {
    final isSelected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(pendingPaymentsFilterProvider.notifier).state = value;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
