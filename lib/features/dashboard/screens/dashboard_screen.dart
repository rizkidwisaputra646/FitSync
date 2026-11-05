import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/user_profile.dart';
import '../../../shared/widgets/fitsync_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../exercises/screens/exercise_detail_screen.dart';
import '../../exercises/screens/exercise_library_screen.dart';
import '../../membership/providers/membership_provider.dart';
import '../../membership/screens/membership_screen.dart';
import '../../profile/screens/edit_profile_screen.dart';
import '../../profile/screens/weight_history_screen.dart';
import '../../workout/providers/workout_provider.dart';
import '../../workout/screens/workout_program_screen.dart';
import '../../../core/utils/haptics_helper.dart';
import '../../../core/widgets/bottom_padding.dart';
import '../../../core/widgets/version_indicator.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  final ScrollController _homeScrollController = ScrollController();

  @override
  void dispose() {
    _homeScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          error: (err, _) => Center(
            child: Text(
              'Gagal memuat data profil: $err',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('Profil tidak ditemukan.'));
            }

            return IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeTab(context, profile),
                const WorkoutProgramScreen(),
                const ExerciseLibraryScreen(),
                const MembershipScreen(),
                _buildProfileTab(context, profile),
              ],
            );
          },
        ),
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
              currentIndex: _currentIndex,
              onTap: (index) {
                HapticsHelper.selection();
                if (index == _currentIndex) {
                  if (index == 0 && _homeScrollController.hasClients) {
                    _homeScrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  }
                  return;
                }
                setState(() => _currentIndex = index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              selectedFontSize: 11.5,
              unselectedFontSize: 11,
              iconSize: 22,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                height: 1.15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                height: 1.15,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_filled),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center_outlined),
                  activeIcon: Icon(Icons.fitness_center_rounded),
                  label: 'Workout',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  activeIcon: Icon(Icons.menu_book_rounded),
                  label: 'Latihan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_2_outlined),
                  activeIcon: Icon(Icons.qr_code_2_rounded),
                  label: 'Membership',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      controller: _homeScrollController,
      padding:
          const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Greeting & Profile Avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${profile.displayName} 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Siap mencapai target kebugaran hari ini?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _currentIndex = 4),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighlight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      profile.displayName.isNotEmpty
                          ? profile.displayName[0].toUpperCase()
                          : 'F',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Calorie & Metabolic Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF19251E), Color(0xFF101A16)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TARGET NUTRISI HARIAN',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          profile.fitnessGoal.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${profile.dailyCalorieTarget.round()}',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 42,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'kkal / hari',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricCol(
                        'BMR Basal', '${profile.bmrEstimate.round()} kkal'),
                    _buildMetricCol(
                        'TDEE Total', '${profile.tdeeEstimate.round()} kkal'),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WeightHistoryScreen(),
                          ),
                        );
                      },
                      child: _buildMetricCol(
                        'Berat Badan',
                        '${profile.currentWeightKg} kg ↗',
                        highlight: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Card: Riwayat Berat Badan & Progres
          FitSyncCard(
            padding: const EdgeInsets.all(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WeightHistoryScreen(),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat & Grafik Berat Badan',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Saat ini: ${profile.currentWeightKg} kg • ${profile.targetWeightKg != null ? "Target: ${profile.targetWeightKg} kg" : "Pantau tren berkala"}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textMuted,
                  size: 14,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // FitSync Membership Quick Status Card
          Consumer(
            builder: (context, ref, _) {
              final membershipAsync = ref.watch(activeMembershipProvider);

              return membershipAsync.maybeWhen(
                data: (mem) {
                  final isActive = mem != null && mem.isActive;

                  return FitSyncCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => setState(() => _currentIndex = 3),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primaryContainer
                                : AppColors.surfaceHighlight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isActive
                                ? Icons.qr_code_2_rounded
                                : Icons.card_membership_rounded,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isActive
                                        ? mem.planName
                                        : 'Akses Gym FitSync',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.primary
                                          : AppColors.surfaceHighlight,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isActive ? 'AKTIF' : 'PILIH PAKET',
                                      style: TextStyle(
                                        color: isActive
                                            ? AppColors.background
                                            : AppColors.textSecondary,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isActive
                                    ? '${mem.remainingLabel} • Ketuk untuk tampilkan Kode QR Check-In'
                                    : 'Pilih Member 1 Bulan atau Harian untuk check-in gym',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textMuted,
                          size: 14,
                        ),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
          const SizedBox(height: 20),

          // 30 Days Program Card
          // 30 Days Program Card
          Consumer(
            builder: (context, ref, _) {
              final completedDays = ref.watch(completedDaysProvider);
              final completedCount = completedDays.length;
              final progressVal = (completedCount / 30.0).clamp(0.0, 1.0);

              return FitSyncCard(
                padding: const EdgeInsets.all(18),
                onTap: () => setState(() => _currentIndex = 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighlight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
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
                                'Program 30 Hari: ${profile.fitnessGoal.title}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Level: ${profile.experienceLevel.title} • ${profile.weeklyWorkoutFrequency}x per minggu',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textMuted,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressVal > 0 ? progressVal : 0.03,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceHighlight,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          completedCount > 0
                              ? '$completedCount dari 30 Hari Selesai'
                              : 'Hari 1 dari 30',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          completedCount > 0
                              ? '${(progressVal * 100).round()}% Selesai'
                              : 'Mulai Hari 1',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: AppColors.secondary,
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
          const SizedBox(height: 20),

          // Rekomendasi Gerakan Berdasarkan Profil
          Text(
            'Rekomendasi Latihan Anda',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _buildRecommendationList(profile),
          const SizedBox(height: 20),

          // Workout Activity Section
          Consumer(
            builder: (context, ref, _) {
              final historyAsync = ref.watch(workoutHistoryProvider);

              return historyAsync.maybeWhen(
                data: (history) {
                  if (history.isEmpty) {
                    return FitSyncCard(
                      padding: const EdgeInsets.all(20),
                      onTap: () => setState(() => _currentIndex = 1),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.fitness_center_rounded,
                            size: 40,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum Ada Sesi Latihan Selesai',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ketuk di sini untuk membuka program 30 hari dan mulai sesi latihan aktif pertama Anda!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final latest = history.first;
                  return FitSyncCard(
                    padding: const EdgeInsets.all(18),
                    onTap: () => setState(() => _currentIndex = 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'SESI LATIHAN TERAKHIR',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'Selesai',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          latest.dayTitle,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Volume: ${latest.totalVolumeKg.round()} kg • ${latest.totalSetsCompleted} Set • ${latest.formattedDuration}',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.textMuted,
                              size: 13,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
          const BottomPadding(minimum: 24),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, {bool highlight = false}) {
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
            color: highlight ? AppColors.primary : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationList(UserProfile profile) {
    // Rekomendasi rule-based cerdas berdasarkan level & alat pengguna
    final eq = profile.availableEquipment;
    final items = [
      if (eq.contains('Barbell'))
        {
          'id': 'barbell-bench-press',
          'name': 'Barbell Bench Press',
          'target': 'Chest',
          'reps': '3 Set x 8-10 Reps'
        },
      if (eq.contains('Lat Pulldown Machine'))
        {
          'id': 'lat-pulldown',
          'name': 'Lat Pulldown',
          'target': 'Back',
          'reps': '3 Set x 10-12 Reps'
        },
      if (eq.contains('Dumbbell'))
        {
          'id': 'dumbbell-lateral-raise',
          'name': 'Dumbbell Lateral Raise',
          'target': 'Shoulder',
          'reps': '3 Set x 10-12 Reps'
        },
      if (eq.contains('Leg Press Machine'))
        {
          'id': 'leg-press-45',
          'name': 'Leg Press 45°',
          'target': 'Legs',
          'reps': '4 Set x 10-12 Reps'
        },
    ];

    if (items.isEmpty) {
      items.add({
        'id': 'hanging-leg-raise',
        'name': 'Hanging Leg Raise',
        'target': 'Abs & Core',
        'reps': '3 Set x 15 Reps'
      });
    }

    return Column(
      children: items.map((rec) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FitSyncCard(
            padding: const EdgeInsets.all(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseDetailScreen(
                    exerciseId: rec['id']!,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
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
                        rec['name']!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Target: ${rec['target']} • ${rec['reps']}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProfileTab(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profil Pengguna',
                style: theme.textTheme.headlineLarge,
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded,
                    color: AppColors.primary, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(profile: profile),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User Header Card
          FitSyncCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighlight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      profile.displayName.isNotEmpty
                          ? profile.displayName[0].toUpperCase()
                          : 'F',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.email,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighlight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${profile.experienceLevel.title} Athlete',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: FitSyncCard(
                  padding: const EdgeInsets.all(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(profile: profile),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined,
                          color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Edit Parameter',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FitSyncCard(
                  padding: const EdgeInsets.all(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WeightHistoryScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monitor_weight_outlined,
                          color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Riwayat Berat',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Parameter Fisik & Metabolisme
          Text(
            'Parameter Fisik & Metabolisme',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          FitSyncCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _buildProfileRow('Umur', '${profile.calculatedAge} Tahun'),
                const Divider(),
                _buildProfileRow(
                    'Jenis Kelamin Biologis', profile.sexForBmr.label),
                const Divider(),
                _buildProfileRow('Tinggi Badan', '${profile.heightCm} cm'),
                const Divider(),
                _buildProfileRow(
                    'Berat Badan Saat Ini', '${profile.currentWeightKg} kg'),
                const Divider(),
                _buildProfileRow(
                  'Target Berat Badan',
                  profile.targetWeightKg != null
                      ? '${profile.targetWeightKg} kg'
                      : 'Belum ditentukan',
                ),
                const Divider(),
                _buildProfileRow(
                    'Tingkat Aktivitas Harian', profile.activityLevel.title),
                const Divider(),
                _buildProfileRow('Tujuan Fitness', profile.fitnessGoal.title),
                const Divider(),
                _buildProfileRow(
                    'Estimasi BMR Basal', '${profile.bmrEstimate.round()} kkal'),
                const Divider(),
                _buildProfileRow(
                    'Estimasi TDEE Harian', '${profile.tdeeEstimate.round()} kkal'),
                const Divider(),
                _buildProfileRow(
                  'Target Kalori Rekomendasi',
                  '${profile.dailyCalorieTarget.round()} kkal',
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Logout Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 1),
            ),
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            label: const Text('Keluar dari Akun FitSync'),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceElevated,
                  title: const Text('Konfirmasi Logout'),
                  content: const Text(
                      'Apakah Anda yakin ingin keluar dari sesi FitSync?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authControllerProvider.notifier).signOut();
              }
            },
          ),
          const SizedBox(height: 16),
          const VersionIndicator(),
          const SizedBox(height: 12),
          const BottomPadding(minimum: 24),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
