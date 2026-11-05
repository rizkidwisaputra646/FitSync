import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/haptics_helper.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/admin_role.dart';
import '../providers/admin_provider.dart';
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
  int _catalogSegment = 0; // 0 = Paket, 1 = Latihan

  final List<String> _tabTitles = [
    'Dashboard Ringkasan',
    'Manajemen Member',
    'Verifikasi Pembayaran',
    'Katalog Paket & Latihan',
    'Pengaturan & Hak Akses',
  ];

  @override
  void initState() {
    super.initState();
    // Default peran aktif untuk screen ini adalah Administrator
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentAdminRoleProvider.notifier).state = UserRole.admin;
    });
  }

  void _handleDashboardNavigation(int target) {
    HapticsHelper.selection();
    if (target == 1) {
      setState(() => _currentTabIndex = 1);
    } else if (target == 2) {
      setState(() => _currentTabIndex = 2);
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar dari Admin Portal',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin mengakhiri sesi administrator?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogTab() {
    return Column(
      children: [
        // Clean Segmented Header
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticsHelper.selectionClick();
                    setState(() => _catalogSegment = 0);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _catalogSegment == 0
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Paket Membership',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _catalogSegment == 0
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticsHelper.selectionClick();
                    setState(() => _catalogSegment = 1);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _catalogSegment == 1
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Dataset Gerakan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _catalogSegment == 1
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _catalogSegment == 0
              ? const AdminPlansTab()
              : const AdminExercisesTab(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildCurrentTab() {
      switch (_currentTabIndex) {
        case 0:
          return AdminDashboardTab(
            onNavigateTab: _handleDashboardNavigation,
          );
        case 1:
          return const AdminMembersTab();
        case 2:
          return const AdminPaymentsTab();
        case 3:
          return _buildCatalogTab();
        case 4:
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
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      color: AppColors.primary,
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
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.error, size: 20),
            tooltip: 'Keluar Admin',
            onPressed: () => _confirmSignOut(context),
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
              onTap: (index) {
                HapticsHelper.selectionClick();
                setState(() => _currentTabIndex = index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              selectedFontSize: 11,
              unselectedFontSize: 10,
              iconSize: 21,
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
                  icon: Icon(Icons.category_outlined),
                  activeIcon: Icon(Icons.category_rounded),
                  label: 'Katalog',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.tune_outlined),
                  activeIcon: Icon(Icons.tune_rounded),
                  label: 'Sistem',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
