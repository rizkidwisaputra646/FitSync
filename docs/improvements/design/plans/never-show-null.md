# Fix: Null or empty backend fields display as "null" or blank gaps

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/never-show-null
- **Needs new dependency**: none

## Why

When user profiles, membership details, or exercise attributes return `null`, empty string, or stringified `"null"` from Firestore/API, users see literal `"null"` or awkward blank spaces. An application-wide extension safely guards all string displays and replaces missing values with neat placeholders like `"-"` or `"N/A"`.

## Where

1. Extension file: `lib/core/extensions/string_extensions.dart`.
2. Usage locations:
   - `lib/features/profile/screens/profile_screen.dart` (displaying user bio, phone, target weight)
   - `lib/features/dashboard/screens/dashboard_screen.dart` (displaying streak count or membership badge)
   - `lib/features/admin/screens/tabs/admin_members_tab.dart` (displaying member phone / notes)

```dart
// lib/features/profile/screens/profile_screen.dart — current
Text(
  user.phone ?? '-',
  style: const TextStyle(color: AppColors.textSecondary),
)
```

## The fix

Create `lib/core/extensions/string_extensions.dart`:

```dart
// target
extension StringX on String? {
  bool get isUsable {
    return this != null && this!.isNotEmpty && this != 'null';
  }

  String orPlaceholder([String placeholder = '-']) {
    if (!isUsable) return placeholder;
    return this!;
  }
}
```

Use `user.phone.orPlaceholder()` and `user.bio.orPlaceholder('Belum ada bio')`.

## Steps

1. Create `lib/core/extensions/string_extensions.dart` with `isUsable` and `orPlaceholder()`.
2. In `lib/features/profile/screens/profile_screen.dart`, import the extension and replace raw fallbacks with `.orPlaceholder()`.
3. In `lib/features/admin/screens/tabs/admin_members_tab.dart`, apply `.orPlaceholder()` to optional user attributes.

## Check it

`dart analyze` exits clean.
`grep -c "orPlaceholder" lib/core/extensions/string_extensions.dart` -> 1.
`grep -c "orPlaceholder" lib/features/profile/screens/profile_screen.dart` -> 1.

## Don't touch

- Do not alter Firebase model schemas or entity properties.
- Do not alter validation logic in input form validators.

## STOP if

- A field requires an integer or boolean where string extension cannot be applied directly (convert with `?.toString().orPlaceholder()`).

## When you're done

Profile pages, admin tables, and dashboard cards consistently display clean dashes (`-`) or appropriate placeholders instead of `null` or unstyled empty boxes.

