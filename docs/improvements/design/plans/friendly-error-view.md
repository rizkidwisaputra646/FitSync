# Fix: Broken widget builds display ugly red crash screens or blank grey boxes

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/friendly-error-view
- **Needs new dependency**: none

## Why

When an unexpected rendering error occurs in a sub-tree widget, Flutter displays a jarring red screen in debug mode and a stark empty grey box in release builds. Users should see an elegant, on-brand message in FitSync's dark colors, while allowing developers to copy the full stack trace with a discreet long-press.

## Where

1. Component file: `lib/core/widgets/friendly_error_view.dart`.
2. Installation location: `lib/main.dart:32` (before `runApp`).

```dart
// lib/main.dart:32 — current
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
```

## The fix

Create `lib/core/widgets/friendly_error_view.dart`:

```dart
// target
import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_colors.dart';

class FriendlyErrorView extends StatefulWidget {
  const FriendlyErrorView({super.key, required this.details});
  final FlutterErrorDetails details;

  @override
  State<FriendlyErrorView> createState() => _FriendlyErrorViewState();
}

class _FriendlyErrorViewState extends State<FriendlyErrorView> {
  bool _copied = false;

  Future<void> _copy() async {
    HapticFeedback.mediumImpact();
    await Clipboard.setData(
      ClipboardData(
        text: '${widget.details.exceptionAsString()}\n\n${widget.details.stack}',
      ),
    );
    if (!mounted) return;
    setState(() => _copied = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Center(
        child: GestureDetector(
          onLongPress: _copy,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.primary, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Terjadi sedikit kendala',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _copied
                      ? 'Log error berhasil disalin ke clipboard'
                      : (kDebugMode
                          ? widget.details.exceptionAsString()
                          : 'Ketuk lama untuk menyalin laporan kendala'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: _copied ? AppColors.primary : AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

And in `lib/main.dart`:

```dart
  ErrorWidget.builder = (details) => FriendlyErrorView(details: details);
```

## Steps

1. Create `lib/core/widgets/friendly_error_view.dart`.
2. In `lib/main.dart`, set `ErrorWidget.builder = (details) => FriendlyErrorView(details: details);` right before `runApp`.

## Check it

`dart analyze` exits clean.
`grep -c "ErrorWidget.builder" lib/main.dart` -> 1.

## Don't touch

- Do not change `WidgetsFlutterBinding.ensureInitialized()` or `FirebaseService.initialize()`.
- Do not suppress errors from crashlytics or logging handlers.

## STOP if

- `ErrorWidget.builder` fails to catch rendering errors inside modal overlays.

## When you're done

Any rendering failure displays an on-brand sporty recovery screen with a long-press shortcut to copy technical diagnostics.

