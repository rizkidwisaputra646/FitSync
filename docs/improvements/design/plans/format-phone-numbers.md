# Fix: Phone numbers displayed and typed as unformatted long runs of digits

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/format-phone-numbers
- **Needs new dependency**: `mask_text_input_formatter: ^2.9.0` (for eager real-time phone masking)

## Why

Raw phone numbers like `081234567890` or `+6281234567890` are hard for users and gym admins to read and verify. Grouping digits into standard formatted chunks (e.g. `+62 812-3456-7890`) prevents input errors and makes contact details legible at a glance.

## Where

1. `pubspec.yaml`
2. Helper file: `lib/core/utils/phone_number_formatter.dart`.
3. `lib/features/profile/screens/edit_profile_screen.dart` (optional contact phone field)
4. `lib/features/admin/screens/tabs/admin_members_tab.dart` (admin member phone display)

## The fix

Create `lib/core/utils/phone_number_formatter.dart`:

```dart
// target
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final indonesianPhoneFormatter = MaskTextInputFormatter(
  mask: '+62 ###-####-####',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.eager,
);

extension PhoneStringX on String {
  String get maskPhoneNumber {
    return indonesianPhoneFormatter.maskText(this);
  }

  String get unmaskPhoneNumber {
    return indonesianPhoneFormatter.unmaskText(this);
  }
}
```

## Steps

1. Add `mask_text_input_formatter: ^2.9.0` to `pubspec.yaml` and run `flutter pub get`.
2. Create `lib/core/utils/phone_number_formatter.dart`.
3. In any phone field, apply `inputFormatters: [indonesianPhoneFormatter]`.
4. In member details or contact display, display using `.maskPhoneNumber`.

## Check it

`dart analyze` exits clean.
`grep -c "indonesianPhoneFormatter" lib/core/utils/phone_number_formatter.dart` -> 1.

## Don't touch

- Do not alter raw unmasked digits passed to backend or SMS auth gateways.
- Do not restrict international prefixes if other countries are selected.

## STOP if

- Masking conflicts with existing form field validation regex.

## When you're done

Phone numbers format automatically into readable groupings like `+62 812-3456-7890` during input and profile display.

