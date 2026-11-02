import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/fitsync_button.dart';
import '../../../../shared/widgets/fitsync_card.dart';
import '../../providers/admin_provider.dart';

class AdminMembersTab extends ConsumerWidget {
  const AdminMembersTab({super.key});

  void _showMemberDetailModal(BuildContext context, WidgetRef ref, Map<String, dynamic> member) {
    final theme = Theme.of(context);
    final status = member['status'] as String? ?? 'active';
    final name = member['displayName'] as String? ?? 'Member';
    final code = member['memberCode'] as String? ?? 'FS-00000';
    final email = member['email'] as String? ?? '-';
    final plan = member['planName'] as String? ?? 'Belum Berlangganan';
    final expiryStr = member['expiryDate'] as String?;
    final expiryDate = expiryStr != null ? DateTime.tryParse(expiryStr) : null;
    final totalCheckins = member['totalCheckins'] ?? 0;

    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Member Info
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'M',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$code • $email',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Membership Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Paket Langganan', plan),
                    const Divider(height: 16),
                    _buildDetailRow(
                      'Status Member',
                      status.toUpperCase(),
                      valueColor: status == 'active'
                          ? AppColors.primary
                          : (status == 'suspended'
                              ? AppColors.error
                              : AppColors.warning),
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      'Masa Berlaku',
                      expiryDate != null ? dateFormat.format(expiryDate) : '-',
                    ),
                    const Divider(height: 16),
                    _buildDetailRow('Total Kunjungan Check-In', '$totalCheckins kali'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Tindakan Manajemen Hak Akses',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: FitSyncButton(
                      text: 'Perpanjang +30 Hari',
                      icon: const Icon(Icons.update_rounded,
                          color: AppColors.background, size: 18),
                      height: 46,
                      onPressed: () async {
                        final nav = Navigator.of(ctx);
                        final messenger = ScaffoldMessenger.of(context);
                        final newExpiry = (expiryDate ?? DateTime.now())
                            .add(const Duration(days: 30));
                        await ref
                            .read(adminActionControllerProvider)
                            .updateMemberStatus(
                              userId: member['uid'],
                              status: 'active',
                              customExpiry: newExpiry,
                              adminNotes: 'Diperpanjang manual oleh admin',
                            );
                        nav.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                'Masa aktif $name berhasil diperpanjang +30 hari.'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FitSyncButton(
                      text: status == 'suspended'
                          ? 'Buka Tangguhan'
                          : 'Tangguhkan',
                      icon: Icon(
                        status == 'suspended'
                            ? Icons.lock_open_rounded
                            : Icons.block_rounded,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                      variant: FitSyncButtonVariant.secondary,
                      height: 46,
                      onPressed: () async {
                        final nav = Navigator.of(ctx);
                        final messenger = ScaffoldMessenger.of(context);
                        final nextStatus =
                            status == 'suspended' ? 'active' : 'suspended';
                        await ref
                            .read(adminActionControllerProvider)
                            .updateMemberStatus(
                              userId: member['uid'],
                              status: nextStatus,
                            );
                        nav.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                'Status $name diubah menjadi $nextStatus.'),
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
    );
  }

  static Widget _buildDetailRow(String label, String value,
      {Color valueColor = AppColors.textPrimary}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredMembers = ref.watch(filteredMembersProvider);
    final currentFilter = ref.watch(memberStatusFilterProvider);
    final allMembersAsync = ref.watch(allMembersProvider);

    return Column(
      children: [
        // Top Search Bar
        Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, top: 14, bottom: 8),
          child: TextField(
            onChanged: (val) {
              ref.read(memberSearchQueryProvider.notifier).state = val;
            },
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Cari nama, email, atau nomor member (FS-XXXXX)...',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.primary, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),

        // Filter Status Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Row(
            children: [
              _buildFilterChip(ref, 'all', 'Semua Member', currentFilter),
              const SizedBox(width: 8),
              _buildFilterChip(ref, 'active', 'Member Aktif', currentFilter),
              const SizedBox(width: 8),
              _buildFilterChip(ref, 'expired', 'Kedaluwarsa', currentFilter),
              const SizedBox(width: 8),
              _buildFilterChip(ref, 'suspended', 'Ditangguhkan', currentFilter),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Member List
        Expanded(
          child: allMembersAsync.when(
            data: (_) {
              if (filteredMembers.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada member ditemukan dengan kriteria ini.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                itemCount: filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = filteredMembers[index];
                  final name = member['displayName'] as String? ?? 'Member';
                  final code = member['memberCode'] as String? ?? 'FS-00000';
                  final plan = member['planName'] as String? ?? 'Belum Berlangganan';
                  final status = member['status'] as String? ?? 'active';

                  Color statusColor = AppColors.primary;
                  String statusLabel = 'AKTIF';
                  if (status == 'expired') {
                    statusColor = AppColors.warning;
                    statusLabel = 'KEDALUWARSA';
                  } else if (status == 'suspended') {
                    statusColor = AppColors.error;
                    statusLabel = 'SUSPENDED';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FitSyncCard(
                      padding: const EdgeInsets.all(14),
                      onTap: () => _showMemberDetailModal(context, ref, member),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHighlight,
                              shape: BoxShape.circle,
                              border: Border.all(color: statusColor, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'M',
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      code,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  plan,
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
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor, width: 0.8),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
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
              child: Text('Gagal memuat daftar member: $err'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref,
    String value,
    String label,
    String current,
  ) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () {
        ref.read(memberStatusFilterProvider.notifier).state = value;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
