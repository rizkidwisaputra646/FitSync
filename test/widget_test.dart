import 'package:flutter_test/flutter_test.dart';
import 'package:fitsync/app/app.dart';
import 'package:fitsync/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('FitSyncApp initial pump test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const FitSyncApp(),
      ),
    );

    // Initial render should show FitSync branding
    expect(find.byType(FitSyncApp), findsOneWidget);
  });
}
