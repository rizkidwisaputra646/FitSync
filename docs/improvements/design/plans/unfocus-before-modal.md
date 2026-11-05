# Fix: Keyboard re-opens unexpectedly when closing modals and bottom sheets

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/unfocus-before-modal
- **Needs new dependency**: none

## Why

If a user focuses a search field or text input and then taps a button that opens a bottom sheet or dialog (e.g. exercise filter sheet, payment modal, confirmation prompt), the soft keyboard disappears while the modal is up, but re-appears and re-focuses the input field the moment the modal closes. Explicitly calling `FocusManager.instance.primaryFocus?.unfocus()` before launching modals prevents this distracting bounce-back.

## Where

1. `lib/features/exercises/screens/exercise_library_screen.dart:41` (_openFilterModal while search bar is focused)
2. `lib/features/membership/screens/membership_screen.dart` (opening purchase confirmation sheet)
3. `lib/features/dashboard/screens/dashboard_screen.dart:1112` (opening logout confirmation dialog)

```dart
// lib/features/exercises/screens/exercise_library_screen.dart:41 — current
  void _openFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
```

## The fix

Unfocus the active primary focus before invoking the modal:

```dart
// target
  void _openFilterModal(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();

    showModalBottomSheet(
      context: context,
```

## Steps

1. In `lib/features/exercises/screens/exercise_library_screen.dart`, add `FocusManager.instance.primaryFocus?.unfocus();` as the first line of `_openFilterModal`.
2. In `lib/features/membership/screens/membership_screen.dart`, add `FocusManager.instance.primaryFocus?.unfocus();` before invoking payment bottom sheets.
3. In `lib/features/dashboard/screens/dashboard_screen.dart`, add `FocusManager.instance.primaryFocus?.unfocus();` before invoking `showDialog`.

## Check it

`dart analyze` exits clean.
`grep -c "FocusManager.instance.primaryFocus?.unfocus()" lib/features/exercises/screens/exercise_library_screen.dart` -> 1.

## Don't touch

- Do not use `FocusScope.of(context).unfocus()`, which only looks for the nearest local scope and may miss the true focused node.
- Do not modify modal sheet content or return values.

## STOP if

- Code at `_openFilterModal` has been removed or restructured into a route.

## When you're done

Opening and closing filter sheets or action dialogs is silky smooth; the keyboard stays dismissed once the modal closes.

