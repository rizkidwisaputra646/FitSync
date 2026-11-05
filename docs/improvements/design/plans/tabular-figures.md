# Fix: Numbers jump and twitch horizontally as seconds change in workout timers

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/tabular-figures
- **Needs new dependency**: none

## Why

In standard proportional fonts, `1` is thinner than `8`. When seconds tick by in active workout and rest timers, the adjacent digits jitter left and right. Enabling `FontFeature.tabularFigures()` gives every digit equal monospaced width within the brand font (Inter), preventing jumping numbers while maintaining modern aesthetic.

## Where

1. `lib/features/workout/screens/active_workout_screen.dart:77` (elapsed workout timer)
2. `lib/features/workout/widgets/rest_timer_modal.dart:70` (rest interval countdown timer)

```dart
// lib/features/workout/screens/active_workout_screen.dart:77 — current
              Text(
                state.formattedElapsedTime,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
```

## The fix

Replace `fontFamily: 'monospace'` with `GoogleFonts.inter` using `FontFeature.tabularFigures()`:

```dart
// target
              Text(
                state.formattedElapsedTime,
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
```

And in `lib/features/workout/widgets/rest_timer_modal.dart:70`:

```dart
// target
              Text(
                _formattedTime,
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
```

## Steps

1. In `lib/features/workout/screens/active_workout_screen.dart`, import `dart:ui` for `FontFeature` and update timer text style with `fontFeatures: const [FontFeature.tabularFigures()]`.
2. In `lib/features/workout/widgets/rest_timer_modal.dart`, update countdown timer text style with `FontFeature.tabularFigures()`.

## Check it

`dart analyze` exits clean.
`grep -c "FontFeature.tabularFigures()" lib/features/workout/screens/active_workout_screen.dart` -> 1.
`grep -c "FontFeature.tabularFigures()" lib/features/workout/widgets/rest_timer_modal.dart` -> 1.

## Don't touch

- Do not apply tabular figures globally to body paragraphs or general text themes.
- Do not modify elapsed duration logic in `active_workout_notifier.dart`.

## STOP if

- Timer formatting string outputs non-numeric symbols that disrupt alignment.

## When you're done

The active workout timer and rest countdown tick smoothly without jumping or wiggling, seamlessly matching FitSync's Inter typography.

