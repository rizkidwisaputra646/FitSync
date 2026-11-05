# Fix: Virtual keyboard stays stuck on screen when user scrolls forms

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/dismiss-keyboard-on-scroll
- **Needs new dependency**: none

## Why

After filling out an input field, users naturally drag the screen up to view subsequent fields or the submit button. Without dismissal behavior, the keyboard remains up, covering half the screen and forcing the user to tap away or hit back. Adding `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` automatically unfocuses inputs and glides the keyboard away when scrolling begins.

## Where

1. `lib/features/auth/screens/login_screen.dart:63`
2. `lib/features/auth/screens/register_screen.dart:74`
3. `lib/features/profile/screens/edit_profile_screen.dart`
4. `lib/features/exercises/screens/edit_custom_exercise_screen.dart`

```dart
// lib/features/auth/screens/login_screen.dart:63 — current
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
```

## The fix

Add `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag`:

```dart
// target
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
```

## Steps

1. In `lib/features/auth/screens/login_screen.dart`, add `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` to the `SingleChildScrollView`.
2. In `lib/features/auth/screens/register_screen.dart`, add `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` to the `SingleChildScrollView`.
3. In `lib/features/profile/screens/edit_profile_screen.dart`, add `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` to the scrollable body.
4. In `lib/features/exercises/screens/edit_custom_exercise_screen.dart`, add `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` to the scrollable body.

## Check it

`dart analyze` exits clean.
`grep -c "ScrollViewKeyboardDismissBehavior.onDrag" lib/features/auth/screens/login_screen.dart` -> 1.
`grep -c "ScrollViewKeyboardDismissBehavior.onDrag" lib/features/auth/screens/register_screen.dart` -> 1.

## Don't touch

- Do not set `onDrag` on chat streams or live logs where user writes while scrolling history.
- Do not remove form keys or existing controllers.

## STOP if

- Scroll view does not accept `keyboardDismissBehavior`.

## When you're done

Dragging down on login, registration, and edit profile screens smoothly dismisses the keyboard, freeing up screen real estate for the user.

