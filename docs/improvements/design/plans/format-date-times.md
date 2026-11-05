# Fix: Raw ISO date strings and unformatted timestamps displayed to users

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/format-date-times
- **Needs new dependency**: none (`intl` is already installed)

## Why

Raw timestamps like `2026-11-03 16:30:00.000` or split ISO strings read like technical database logs. Dates should always be formatted into friendly natural language like `3 Nov 2026, 16:30` or `Hari ini / Kemarin` in the user's language.

## Where

1. Extension file: `lib/core/extensions/datetime_extensions.dart`.
2. Usage screens:
   - `lib/features/profile/screens/weight_history_screen.dart:296`
   - `lib/features/admin/screens/tabs/admin_checkin_tab.dart` (check-in time logs)
   - `lib/features/admin/screens/tabs/admin_payments_tab.dart` (transaction date)

```dart
// lib/features/profile/screens/weight_history_screen.dart:296 — current
_formatDate(item.loggedAt)
```

## The fix

Create `lib/core/extensions/datetime_extensions.dart`:

```dart
// target
import 'package:intl/intl.dart';

extension DateTimeX on DateTime? {
  String formattedDateTime([String locale = 'id_ID']) {
    if (this == null) return 'N/A';
    return DateFormat('d MMMM yyyy, HH:mm', locale).format(this!);
  }

  String formattedDate([String locale = 'id_ID']) {
    if (this == null) return 'N/A';
    return DateFormat('d MMM yyyy', locale).format(this!);
  }

  String formattedTime() {
    if (this == null) return 'N/A';
    return DateFormat('HH:mm').format(this!);
  }

  bool get isToday {
    if (this == null) return false;
    final now = DateTime.now();
    return this!.year == now.year && this!.month == now.month && this!.day == now.day;
  }

  bool get isYesterday {
    if (this == null) return false;
    final yest = DateTime.now().subtract(const Duration(days: 1));
    return this!.year == yest.year && this!.month == yest.month && this!.day == yest.day;
  }

  String formattedDayOrDate([String locale = 'id_ID']) {
    if (this == null) return 'N/A';
    if (isToday) return 'Hari ini';
    if (isYesterday) return 'Kemarin';
    return formattedDate(locale);
  }
}
```

## Steps

1. Create `lib/core/extensions/datetime_extensions.dart`.
2. In `lib/features/profile/screens/weight_history_screen.dart`, replace local date formatting with `item.loggedAt.formattedDate()`.
3. In `lib/features/admin/screens/tabs/admin_checkin_tab.dart`, replace timestamp display with `.formattedDayOrDate()` and `.formattedTime()`.

## Check it

`dart analyze` exits clean.
`grep -c "formattedDayOrDate" lib/core/extensions/datetime_extensions.dart` -> 1.
`grep -c "formattedDate" lib/features/profile/screens/weight_history_screen.dart` -> 1.

## Don't touch

- Do not change `toIso8601String()` used when serializing models to Firestore databases.
- Do not alter date comparison queries in repositories.

## STOP if

- Locale data is missing for Indonesian locale (call `initializeDateFormatting('id_ID', null)` if needed).

## When you're done

Check-in histories, weight logs, and membership expiry dates appear as human-readable dates like "Hari ini, 09:15" or "15 Des 2026" instead of cold ISO strings.

