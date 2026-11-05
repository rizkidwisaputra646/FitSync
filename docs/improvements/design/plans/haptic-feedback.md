# Fix: Key interactions like set completions and tab changes lack tactile feedback

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/haptic-feedback
- **Needs new dependency**: `haptic_feedback: ^0.5.1` (for richer vibrations like light, success, selection)

## Why

The app feels flat and silent when users tap tabs, check off workout sets, or finish an intense workout session. Subtle haptic pulses on set completion and navigation provide reassuring physical confirmation that feels premium in the hand.

## Where

1. Helper file: `lib/core/utils/haptics_helper.dart`.
2. Usage screens:
   - `lib/features/dashboard/screens/dashboard_screen.dart` (bottom navigation tab taps)
   - `lib/features/workout/screens/active_workout_screen.dart` (marking a set completed)
   - `lib/features/workout/screens/active_workout_screen.dart` (completing entire workout session)

```dart
// lib/features/dashboard/screens/dashboard_screen.dart:180 — current
onTap: (index) {
  setState(() => _currentIndex = index);
},
```

## The fix

Create `lib/core/utils/haptics_helper.dart`:

```dart
// target
import 'package:haptic_feedback/haptic_feedback.dart';

class HapticsHelper {
  HapticsHelper._();

  static bool? _canVibrate;

  static Future<void> _vibrate(HapticsType type) async {
    _canVibrate ??= await Haptics.canVibrate();
    if (_canVibrate ?? false) {
      await Haptics.vibrate(type);
    }
  }

  static Future<void> success() => _vibrate(HapticsType.success);
  static Future<void> warning() => _vibrate(HapticsType.warning);
  static Future<void> error() => _vibrate(HapticsType.error);
  static Future<void> light() => _vibrate(HapticsType.light);
  static Future<void> medium() => _vibrate(HapticsType.medium);
  static Future<void> selection() => _vibrate(HapticsType.selection);
}
```

Trigger `HapticsHelper.selection()` on tab change and `HapticsHelper.success()` on completing a set.

## Steps

1. Add `haptic_feedback: ^0.5.1` to `pubspec.yaml` and run `flutter pub get`.
2. Create `lib/core/utils/haptics_helper.dart`.
3. In `lib/features/dashboard/screens/dashboard_screen.dart`, call `HapticsHelper.selection()` inside `onTap`.
4. In `lib/features/workout/screens/active_workout_screen.dart`, call `HapticsHelper.success()` when toggling a set as completed.

## Check it

`dart analyze` exits clean.
`grep -c "HapticsHelper" lib/features/dashboard/screens/dashboard_screen.dart` -> 1.
`grep -c "HapticsHelper" lib/features/workout/screens/active_workout_screen.dart` -> 1.

## Don't touch

- Do not trigger haptics inside passive build methods or continuous drag listeners.
- Do not affect web platform execution (guarded by `canVibrate`).

## STOP if

- Platform build fails due to native vibration permissions.

## When you're done

Checking off a workout set produces a crisp tactile click, and switching tabs gives a gentle confirmation pulse.

