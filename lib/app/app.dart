import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/admin/screens/admin_main_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/onboarding/screens/fitness_profile_setup_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/splash/screens/welcome_screen.dart';
import '../features/staff/screens/staff_main_screen.dart';
import 'theme/app_theme.dart';

class AlwaysScrollbarBehavior extends MaterialScrollBehavior {
  const AlwaysScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(
      controller: details.controller,
      child: child,
    );
  }
}

class FitSyncApp extends ConsumerWidget {
  const FitSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FitSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      scrollBehavior: const AlwaysScrollbarBehavior(),
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
        // 1. Jika belum login -> arahkan ke WelcomeScreen (Cinematic Hero)
        if (session == null) {
          return const WelcomeScreen();
        }

        final lowerEmail = session.email.toLowerCase();

        // 2. Deteksi instan peran dari kredensial email akun
        if (lowerEmail.contains('admin')) {
          return const AdminMainScreen();
        }
        if (lowerEmail.contains('petugas') || lowerEmail.contains('staff')) {
          return const StaffMainScreen();
        }

        // 3. Pantau profil pengguna
        final profileAsync = ref.watch(currentUserProfileProvider);

        return profileAsync.when(
          loading: () => const SplashScreen(),
          error: (error, _) => Scaffold(
            body: Center(
              child: Text('Gagal memuat profil pengguna: $error'),
            ),
          ),
          data: (profile) {
            // Cek role dari database profil
            if (profile != null) {
              if (profile.isAdmin) return const AdminMainScreen();
              if (profile.isStaff) return const StaffMainScreen();
            }

            // Jika member baru dan profil belum lengkap -> Wajib Fitness Profile Setup
            if (profile == null || !profile.profileCompleted) {
              return const FitnessProfileSetupScreen();
            }

            // Jika profil member sudah lengkap -> Dashboard utama member
            return const DashboardScreen();
          },
        );
      },
    );
  }
}
