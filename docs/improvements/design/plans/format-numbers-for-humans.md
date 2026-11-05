# Fix: Large numbers, weights, and currency amounts displayed as raw unformatted digits

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/format-numbers-for-humans
- **Needs new dependency**: none (`intl` is already installed in `pubspec.yaml:45`)

## Why

Raw unformatted numbers like `250000` or `12500` are hard for users to parse at a glance. Displaying numbers formatted for the user's locale (e.g. `Rp 250.000` or `12,500 kg`) makes stats, prices, and workout volumes instantly readable and professional.

## Where

1. Extension file: `lib/core/extensions/number_extensions.dart`.
2. Usage screens:
   - `lib/features/membership/screens/membership_screen.dart` (membership package prices)
   - `lib/features/dashboard/screens/dashboard_screen.dart` (calories burned, active minutes, total workout volume)
   - `lib/features/workout/screens/workout_summary_modal.dart` (workout summary volume and calories)

```dart
// lib/features/membership/screens/membership_screen.dart — current
Text('Rp ${plan.price}')
```

## The fix

Create `lib/core/extensions/number_extensions.dart`:

```dart
// target
import 'package:intl/intl.dart';

extension NumX on num {
  String humanizedCount({int? decimalDigits}) {
    return NumberFormat.decimalPatternDigits(
      decimalDigits: decimalDigits,
    ).format(this);
  }

  String humanizedCurrency([String code = 'IDR']) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(this);
  }

  String humanizedCompact() {
    return NumberFormat.compact().format(this);
  }
}
```

## Steps

1. Create `lib/core/extensions/number_extensions.dart`.
2. In `lib/features/membership/screens/membership_screen.dart`, format prices using `plan.price.humanizedCurrency()`.
3. In `lib/features/dashboard/screens/dashboard_screen.dart`, format total volume and calorie counts using `.humanizedCount()`.

## Check it

`dart analyze` exits clean.
`grep -c "humanizedCurrency" lib/features/membership/screens/membership_screen.dart` -> 1.
`grep -c "humanizedCount" lib/features/dashboard/screens/dashboard_screen.dart` -> 1.

## Don't touch

- Do not change raw integer or double types stored in models or Firestore.
- Do not format ID numbers, database keys, or version strings.

## STOP if

- `intl` package throws locale data errors (ensure `intl` initialization if specific non-standard locale is requested).

## When you're done

Membership plan prices appear cleanly as `Rp 250.000` and workout volumes appear as `12.500 kg` with proper grouping separators.

