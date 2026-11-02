import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../models/admin_role.dart';
import '../providers/admin_provider.dart';
import 'tabs/admin_checkin_tab.dart';
import 'tabs/admin_dashboard_tab.dart';
import 'tabs/admin_exercises_tab.dart';
import 'tabs/admin_members_tab.dart';
import 'tabs/admin_payments_tab.dart';
import 'tabs/admin_plans_tab.dart';
import 'tabs/admin_settings_tab.dart';

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  int _currentTabIndex = 0;

  final List<String> _tabTitles = [
    'Dashboard Ringkasan',
    'Manajemen Member',
    'Verifikasi Pembayaran',
    'Check-In & Turnstile',
    'Paket Membership',
    'Manajemen Latihan',
    'Pengaturan & Hak Akses',
  ];

  Widget _buildRoleRestrictedView(String moduleName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Akses Terbatas: Administrator Only',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Modul $moduleName hanya dapat diakses oleh peran Administrator. Peran Anda saat ini adalah Petugas Gym.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceHighlight,
                foregroundColor: AppColors.primary,
              ),
              onPressed: () => setState(() => _currentTabIndex = 6),
              child: const Text('Buka Pengaturan Role'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentAdminRoleProvider);

    Widget buildCurrentTab() {
      switch (_currentTabIndex) {
        case 0:
          return AdminDashboardTab(
            onNavigateTab: (target) => setState(() => _currentTabIndex = target),
          );
        case 1:
          if (!role.canManageMembers) {
            return _buildRoleRestrictedView('Manajemen Member');
          }
          return const AdminMembersTab();
        case 2:
          if (!role.canVerifyPayments) {
            return _buildRoleRestrictedView('Verifikasi Pembayaran');
          }
          return const AdminPaymentsTab();
        case 3:
          return const AdminCheckinTab();
        case 4:
          if (!role.canManagePlans) {
            return _buildRoleRestrictedView('Paket Membership');
          }
          return const AdminPlansTab();
        case 5:
          if (!role.canManageExercises) {
            return _buildRoleRestrictedView('Manajemen Latihan');
          }
          return const AdminExercisesTab();
        case 6:
          return const AdminSettingsTab();
        default:
          return const SizedBox.shrink();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'FITSYNC ADMIN',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: role == UserRole.admin
                        ? AppColors.primaryContainer
                        : const Color(0xFF38BDF8).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    role == UserRole.admin ? 'ADMIN' : 'PETUGAS',
                    style: TextStyle(
                      color: role == UserRole.admin
                          ? AppColors.primary
                          : const Color(0xFF38BDF8),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              _tabTitles[_currentTabIndex],
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.error, size: 22),
            tooltip: 'Kembali ke Aplikasi Member',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: buildCurrentTab(),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.8),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: BottomNavigationBar(
              currentIndex: _currentTabIndex,
              onTap: (index) => setState(() => _currentTabIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              selectedFontSize: 10,
              unselectedFontSize: 9.5,
              iconSize: 20,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                height: 1.15,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: 'Ringkasan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  activeIcon: Icon(Icons.people_rounded),
                  label: 'Member',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long_rounded),
                  label: 'Bayar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner_outlined),
                  activeIcon: Icon(Icons.qr_code_scanner_rounded),
                  label: 'Turnstile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.card_membership_outlined),
                  activeIcon: Icon(Icons.card_membership_rounded),
                  label: 'Paket',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center_outlined),
                  activeIcon: Icon(Icons.fitness_center_rounded),
                  label: 'Latihan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings_rounded),
                  label: 'Akses',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
