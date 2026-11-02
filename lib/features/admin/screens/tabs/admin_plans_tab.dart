import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../models/membership_plan.dart';
import '../../../../shared/widgets/fitsync_button.dart';
import '../../../../shared/widgets/fitsync_card.dart';
import '../../providers/admin_provider.dart';

class AdminPlansTab extends ConsumerWidget {
  const AdminPlansTab({super.key});

  void _showAddEditPlanModal(BuildContext context, WidgetRef ref, [MembershipPlan? planToEdit]) {
    final isEditing = planToEdit != null;
    final nameCtrl = TextEditingController(text: planToEdit?.name ?? '');
    final priceCtrl = TextEditingController(text: planToEdit?.price.toString() ?? '');
    final daysCtrl = TextEditingController(text: planToEdit?.durationDays.toString() ?? '30');
    final descCtrl = TextEditingController(text: planToEdit?.description ?? '');
    final featuresCtrl = TextEditingController(
      text: planToEdit != null ? planToEdit.features.join('\n') : '',
    );
    bool isPopular = planToEdit?.isPopular ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Paket Membership' : 'Tambah Paket Baru',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildField('Nama Paket', nameCtrl, 'Contoh: Member 3 Bulan (Quarterly)'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildField('Harga (Rp)', priceCtrl, '250000', TextInputType.number),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildField('Durasi (Hari)', daysCtrl, '30', TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildField('Deskripsi Paket', descCtrl, 'Deskripsi singkat benefit paket...'),
                const SizedBox(height: 10),
                _buildField(
                  'Fitur (1 baris per fitur)',
                  featuresCtrl,
                  'Akses gym 30 hari\nLoker & shower\nFree Wi-Fi',
                  TextInputType.multiline,
                  3,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tandai sebagai Paket Populer (Best Value)',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 12.5),
                    ),
                    Switch(
                      value: isPopular,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setModalState(() => isPopular = val),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FitSyncButton(
                  text: isEditing ? 'Simpan Perubahan' : 'Buat Paket Baru',
                  icon: const Icon(Icons.check_rounded, color: AppColors.background, size: 18),
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
                    final days = int.tryParse(daysCtrl.text.trim()) ?? 30;
                    final desc = descCtrl.text.trim();
                    final features = featuresCtrl.text
                        .split('\n')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    if (name.isEmpty || price <= 0) return;

                    final formattedPrice = 'Rp ${price.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]}.',
                        )}';

                    final newPlan = MembershipPlan(
                      id: planToEdit?.id ??
                          'plan_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
                      name: name,
                      badge: isPopular ? 'PILIHAN TERPOPULER' : (days == 1 ? 'DAILY PASS' : 'PRO PASS'),
                      price: price,
                      formattedPrice: formattedPrice,
                      periodLabel: days == 1 ? '/ 24 Jam' : '/ $days Hari',
                      durationDays: days,
                      durationHours: days * 24,
                      description: desc,
                      features: features.isNotEmpty
                          ? features
                          : ['Akses penuh fasilitas gym FitSync'],
                      isPopular: isPopular,
                    );

                    final nav = Navigator.of(ctx);
                    final messenger = ScaffoldMessenger.of(context);
                    await ref.read(adminActionControllerProvider).savePlan(newPlan);
                    nav.pop();
                    messenger.showSnackBar(
                      SnackBar(content: Text('Paket $name berhasil disimpan.')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, [
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(adminPlansListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manajemen Paket Membership',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Kelola harga, durasi, dan keuntungan paket gym.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.primary, size: 28),
                onPressed: () => _showAddEditPlanModal(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 14),

          plansAsync.when(
            data: (plans) {
              return Column(
                children: plans.map((plan) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FitSyncCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${plan.formattedPrice} ${plan.periodLabel} • ${plan.durationDays} Hari',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 18, color: AppColors.textSecondary),
                                onPressed: () =>
                                    _showAddEditPlanModal(context, ref, plan),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            plan.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: plan.features.take(3).map((f) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHighlight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  f,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10.5,
                                  ),
                                ),
                              );
                            }).toList(),
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
            error: (err, _) => Center(
              child: Text('Gagal memuat paket: $err'),
            ),
          ),
        ],
      ),
    );
  }
}
