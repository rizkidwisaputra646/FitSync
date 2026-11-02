import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../models/fitness_enums.dart';
import '../../../shared/widgets/fitsync_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/step_calculation_results.dart';
import '../widgets/step_daily_activity.dart';
import '../widgets/step_fitness_goals.dart';
import '../widgets/step_personal_data.dart';

class FitnessProfileSetupScreen extends ConsumerStatefulWidget {
  const FitnessProfileSetupScreen({super.key});

  @override
  ConsumerState<FitnessProfileSetupScreen> createState() =>
      _FitnessProfileSetupScreenState();
}

class _FitnessProfileSetupScreenState
    extends ConsumerState<FitnessProfileSetupScreen> {
  final _step1Key = GlobalKey<State<StepPersonalData>>();
  final _step3Key = GlobalKey<State<StepFitnessGoals>>();

  void _onNextPressed() {
    final state = ref.read(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    if (state.currentStep == 1) {
      // Trigger validasi di Step 1
      (_step1Key.currentState as dynamic)?.validateAndProceed();
    } else if (state.currentStep == 2) {
      notifier.setStep(3);
    } else if (state.currentStep == 3) {
      // Trigger validasi di Step 3
      (_step3Key.currentState as dynamic)?.validateAndProceed();
    } else if (state.currentStep == 4) {
      _saveAndFinish();
    }
  }

  void _saveAndFinish() async {
    final notifier = ref.read(onboardingProvider.notifier);
    final success = await notifier.saveProfileAndFinish();
    if (!success && mounted) {
      final state = ref.read(onboardingProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Gagal menyimpan profil.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Setup Profil Fitness'),
        leading: state.currentStep > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => notifier.setStep(state.currentStep - 1),
              )
            : null,
        actions: [
          IconButton(
            tooltip: 'Keluar / Ganti Akun',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceElevated,
                  title: const Text('Keluar dari Akun?'),
                  content: const Text(
                    'Anda dapat melanjutkan pengisian profil fitness nanti saat masuk kembali.',
                  ),
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
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Step Progress Indicator (1 to 4)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: AppColors.surface,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Langkah ${state.currentStep} dari 4',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        state.currentStep == 1
                            ? 'Data Fisik'
                            : state.currentStep == 2
                                ? 'Aktivitas Harian'
                                : state.currentStep == 3
                                    ? 'Target & Latihan'
                                    : 'Hasil Analisis',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.currentStep / 4.0,
                      backgroundColor: AppColors.surfaceHighlight,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content per Step
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey<int>(state.currentStep),
                    child: _buildStepContent(state, notifier),
                  ),
                ),
              ),
            ),

            // Bottom Navigation Action Bar
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Row(
                children: [
                  if (state.currentStep > 1) ...[
                    Expanded(
                      flex: 1,
                      child: FitSyncButton(
                        text: 'Kembali',
                        variant: FitSyncButtonVariant.outline,
                        onPressed: () =>
                            notifier.setStep(state.currentStep - 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: FitSyncButton(
                      text: state.currentStep == 4
                          ? 'Simpan Profil & Mulai FitSync'
                          : 'Lanjutkan',
                      isLoading: state.isSaving,
                      onPressed: state.isSaving ? null : _onNextPressed,
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

  Widget _buildStepContent(OnboardingState state, OnboardingNotifier notifier) {
    switch (state.currentStep) {
      case 1:
        return StepPersonalData(
          key: _step1Key,
          initialName: state.fullName,
          initialAge: state.age,
          initialSex: state.sex,
          initialHeight: state.heightCm,
          initialWeight: state.weightKg,
          onValidSubmit: ({
            required String fullName,
            required int age,
            required BiologicalSex sex,
            required double heightCm,
            required double weightKg,
          }) {
            notifier.updatePersonalData(
              fullName: fullName,
              age: age,
              sex: sex,
              heightCm: heightCm,
              weightKg: weightKg,
            );
            notifier.setStep(2);
          },
        );
      case 2:
        return StepDailyActivity(
          selectedLevel: state.activityLevel,
          onSelect: (level) {
            notifier.updateDailyActivity(level);
          },
        );
      case 3:
        return StepFitnessGoals(
          key: _step3Key,
          initialGoal: state.fitnessGoal,
          initialTargetWeight: state.targetWeightKg,
          initialExperience: state.experienceLevel,
          initialFrequency: state.weeklyWorkoutFrequency,
          initialEquipment: state.availableEquipment,
          initialDuration: state.preferredWorkoutDurationMinutes,
          onValidSubmit: ({
            required goal,
            targetWeightKg,
            required experienceLevel,
            required weeklyFrequency,
            required equipment,
            required preferredDuration,
          }) {
            notifier.updateFitnessGoals(
              goal: goal,
              targetWeightKg: targetWeightKg,
              experienceLevel: experienceLevel,
              weeklyFrequency: weeklyFrequency,
              equipment: equipment,
              preferredDuration: preferredDuration,
            );
            notifier.setStep(4);
          },
        );
      case 4:
      default:
        final result = state.calculationResult;
        if (result == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return StepCalculationResults(
          result: result,
          currentWeightKg: state.weightKg,
          heightCm: state.heightCm,
          age: state.age,
          sex: state.sex,
          activityLevel: state.activityLevel,
          goal: state.fitnessGoal,
        );
    }
  }
}
