import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/onboarding/screens/fitness_profile_setup_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import 'theme/app_theme.dart';

class FitSyncApp extends ConsumerWidget {
  const FitSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FitSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGateway(),
    );
  }
}

/// Router gateway yang mengatur alur autentikasi dan onboarding secara otomatis dan aman.
class AuthGateway extends ConsumerWidget {
  const AuthGateway({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const SplashScreen(),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Terjadi kesalahan sesi: $error'),
        ),
      ),
      data: (session) {
        // 1. Jika belum login -> arahkan ke LoginScreen
        if (session == null) {
          return const LoginScreen();
        }

        // 2. Jika sudah login -> pantau UserProfile
        final profileAsync = ref.watch(currentUserProfileProvider);

        return profileAsync.when(
          loading: () => const SplashScreen(),
          error: (error, _) => Scaffold(
            body: Center(
              child: Text('Gagal memuat profil pengguna: $error'),
            ),
          ),
          data: (profile) {
            // Jika profil belum ada atau profil belum lengkap -> Wajib Fitness Profile Setup
            if (profile == null || !profile.profileCompleted) {
              return const FitnessProfileSetupScreen();
            }

            // Jika profil sudah lengkap -> Dashboard utama
            return const DashboardScreen();
          },
        );
      },
    );
  }
}
