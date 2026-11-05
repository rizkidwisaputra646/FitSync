# Fix: App version and build number are hidden from settings and profile

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/show-app-version
- **Needs new dependency**: `package_info_plus: ^8.1.0` (to fetch platform app version and build number dynamically)

## Why

When users report bugs or when team members test builds across environments, there is no in-app indicator to verify what version and build number is currently running. Displaying a subtle, quiet version label at the bottom of the profile tab makes debugging straightforward.

## Where

1. `pubspec.yaml`
2. Component file: `lib/core/widgets/version_indicator.dart`.
3. `lib/features/dashboard/screens/dashboard_screen.dart:1139` (bottom of Profile tab)

```dart
// lib/features/dashboard/screens/dashboard_screen.dart:1139 — current
              if (confirm == true) {
                await ref.read(authControllerProvider.notifier).signOut();
              }
            },
          ),
          const SizedBox(height: 20),
        ],
```

## The fix

Create `lib/core/widgets/version_indicator.dart`:

```dart
// target
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../app/theme/app_colors.dart';

class VersionIndicator extends StatefulWidget {
  const VersionIndicator({super.key});

  @override
  State<VersionIndicator> createState() => _VersionIndicatorState();
}

class _VersionIndicatorState extends State<VersionIndicator> {
  String? _label;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _label = 'FitSync v${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_label == null) return const SizedBox.shrink();

    return Center(
      child: Text(
        _label!,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
```

And place `<VersionIndicator />` below logout button in `dashboard_screen.dart:1140`.

## Steps

1. Add `package_info_plus: ^8.1.0` to `pubspec.yaml` and execute `flutter pub get`.
2. Create `lib/core/widgets/version_indicator.dart`.
3. In `lib/features/dashboard/screens/dashboard_screen.dart`, add `const VersionIndicator()` followed by `const SizedBox(height: 16)` right after the logout tile in `_buildProfileTab`.

## Check it

`dart analyze` exits clean.
`grep -c "VersionIndicator" lib/features/dashboard/screens/dashboard_screen.dart` -> 1.

## Don't touch

- Do not alter logout functionality or authentication providers.
- Do not make the version indicator loud or brightly colored (keep it muted).

## STOP if

- `package_info_plus` fails to resolve platform channels on desktop or web.

## When you're done

The bottom of the Profile screen displays a neat, subtle `FitSync v1.0.0 (1)` label for effortless troubleshooting and version verification.

