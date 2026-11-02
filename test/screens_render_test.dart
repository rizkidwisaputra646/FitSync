import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitsync/features/auth/providers/auth_provider.dart';
import 'package:fitsync/features/auth/screens/login_screen.dart';
import 'package:fitsync/features/auth/screens/register_screen.dart';
import 'package:fitsync/features/onboarding/screens/fitness_profile_setup_screen.dart';
import 'package:fitsync/features/profile/screens/weight_history_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('Renders LoginScreen without Material shape/borderRadius assertion',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('FITSYNC'), findsOneWidget);
  });

  testWidgets('Renders RegisterScreen without assertion', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Buat Akun FitSync'), findsOneWidget);
  });

  testWidgets('Renders FitnessProfileSetupScreen without assertion',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: FitnessProfileSetupScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Setup Profil Fitness'), findsOneWidget);
  });

  testWidgets('Renders WeightHistoryScreen without assertion', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: WeightHistoryScreen(),
        ),
      ),
    );
    await tester.pump();
  });
}
