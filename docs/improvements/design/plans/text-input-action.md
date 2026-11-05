# Fix: Virtual keyboard Enter/Action key does not navigate fields or submit forms

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/text-input-action
- **Needs new dependency**: none

## Why

Filling forms like Login and Register requires tapping each field manually. The keyboard's action key defaults to closing the keyboard rather than advancing to the next field. On the final password field, pressing Done/Go should trigger submission directly from the soft keyboard.

## Where

1. `lib/shared/widgets/fitsync_text_field.dart:21` (missing `textInputAction` and `onFieldSubmitted`)
2. `lib/features/auth/screens/login_screen.dart:160` (email and password fields)
3. `lib/features/auth/screens/register_screen.dart:100` (name, email, password fields)

```dart
// lib/shared/widgets/fitsync_text_field.dart:21 — current
  final String? helperText;
  final bool readOnly;
  final VoidCallback? onTap;

  const FitSyncTextField({
```

## The fix

Add `textInputAction` and `onFieldSubmitted` to `FitSyncTextField`:

```dart
// target
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const FitSyncTextField({
    super.key,
    this.controller,
    required this.label,
    this.textInputAction,
    this.onFieldSubmitted,
```

And in `TextFormField`:

```dart
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
```

Then in `lib/features/auth/screens/login_screen.dart`:
- Email field: `textInputAction: TextInputAction.next`
- Password field: `textInputAction: TextInputAction.done`, `onFieldSubmitted: (_) => _handleSignIn()`

## Steps

1. In `lib/shared/widgets/fitsync_text_field.dart`, add `textInputAction` and `onFieldSubmitted` parameters and pass them to the underlying `TextFormField`.
2. In `lib/features/auth/screens/login_screen.dart`, set `textInputAction: TextInputAction.next` on `_emailController` and `textInputAction: TextInputAction.done` with `onFieldSubmitted: (_) => _handleSignIn()` on `_passwordController`.
3. In `lib/features/auth/screens/register_screen.dart`, set `textInputAction: TextInputAction.next` on initial fields and `TextInputAction.done` on confirm password.

## Check it

`dart analyze` exits clean.
`grep -c "textInputAction: TextInputAction.next" lib/features/auth/screens/login_screen.dart` -> 1.
`grep -c "onFieldSubmitted" lib/shared/widgets/fitsync_text_field.dart` -> 2.

## Don't touch

- Do not alter multiline text fields (e.g. bio or workout notes), which need `TextInputAction.newline`.
- Do not modify existing validation rules in `validator`.

## STOP if

- Form submission logic breaks due to asynchronous execution during `onFieldSubmitted`.

## When you're done

Users can type their email, hit the blue "Next" arrow on their keyboard to instantly hop to the password field, and hit "Done" to submit the form without reaching for the button.

