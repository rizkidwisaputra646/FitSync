# Fix: Bottom of scrollable lists cut off or obscured by device navigation bar

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/safe-area-replacement
- **Needs new dependency**: none

## Why

The last item of scrollable lists gets obscured by the system navigation bar or navigation pills on newer Android/iOS devices. Wrapping whole lists in `SafeArea` causes items to abruptly cut off mid-scroll instead of sliding behind the bar. Adding dynamic bottom insets guarantees breathing room at the end of lists while letting content scroll edge-to-edge.

## Where

1. Need shared helper `BottomPadding` in `lib/core/widgets/bottom_padding.dart`.
2. Scrollables across major screens:
   - `lib/features/dashboard/screens/dashboard_screen.dart:133`
   - `lib/features/exercises/screens/exercise_library_screen.dart:336`
   - `lib/features/profile/screens/edit_profile_screen.dart`
   - `lib/features/admin/screens/tabs/admin_dashboard_tab.dart:24`

```dart
// lib/features/dashboard/screens/dashboard_screen.dart:133 — current
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
```

## The fix

Create `BottomPadding` in `lib/core/widgets/bottom_padding.dart`:

```dart
import 'package:flutter/widgets.dart';

class BottomPadding extends StatelessWidget {
  const BottomPadding({super.key, this.minimum = 16});

  final double minimum;

  static double of(
    BuildContext context, {
    double minimum = 16,
  }) {
    final double viewPadding = MediaQuery.viewPaddingOf(context).bottom;
    return viewPadding > minimum ? viewPadding : minimum;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: of(context, minimum: minimum));
  }
}
```

Use `BottomPadding` at the end of scrollable columns, or use `BottomPadding.of(context)` inside scroll padding.

## Steps

1. Create `lib/core/widgets/bottom_padding.dart` with the `BottomPadding` widget and helper method.
2. In `lib/features/dashboard/screens/dashboard_screen.dart`, add `const BottomPadding(minimum: 24)` at the bottom of the main dashboard `Column`.
3. In `lib/features/exercises/screens/exercise_library_screen.dart`, include `bottom: BottomPadding.of(context, minimum: 24)` in `ListView.builder` padding.
4. In `lib/features/profile/screens/edit_profile_screen.dart`, add `const BottomPadding(minimum: 32)` at the end of the form column.

## Check it

`dart analyze` exits clean.
`grep -c "BottomPadding" lib/features/dashboard/screens/dashboard_screen.dart` -> 1.
`grep -c "BottomPadding" lib/core/widgets/bottom_padding.dart` -> 1.

## Don't touch

- Do not modify fixed horizontal padding on existing components.
- Do not shrink viewport bounds with outer `SafeArea` widgets around scrollables.

## STOP if

- Code at specified locations no longer matches.
- `MediaQuery.viewPaddingOf` is unavailable (ensure Flutter 3.10+ / Dart 3+).

## When you're done

The dashboard, exercise library, and profile screens provide comfortable breathing room between the lowest card/button and the device's navigation bar or home indicator.

