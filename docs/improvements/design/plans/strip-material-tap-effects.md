# Fix: Clashing default Material ripple, highlight, and splash effects on custom dark sporty UI

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/strip-material-tap-effects
- **Needs new dependency**: none

## Why

Material widgets default to circular ink ripples, grey hover highlights, and wash overlays on tap. In FitSync's dark, high-contrast, neon lime sporty design language, these default Material effects look sloppy, cheap, and out of place. Disabling global ink ripples and setting transparent overlays produces crisp, intentional touch states.

## Where

In `lib/app/theme/app_theme.dart:11`:

```dart
// lib/app/theme/app_theme.dart:11 — current
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
```

## The fix

Configure `NoSplash.splashFactory` and transparent overlay colors globally in `AppTheme.darkTheme`:

```dart
// target
    final ButtonStyle noSplash = ButtonStyle(
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      splashColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      iconButtonTheme: IconButtonThemeData(style: noSplash),
      textButtonTheme: TextButtonThemeData(style: noSplash),
      navigationBarTheme: NavigationBarThemeData(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
```

## Steps

1. Open `lib/app/theme/app_theme.dart`.
2. Add `final ButtonStyle noSplash` helper.
3. Configure `splashColor: Colors.transparent`, `splashFactory: NoSplash.splashFactory`, `highlightColor: Colors.transparent`, `hoverColor: Colors.transparent`, and `focusColor: Colors.transparent`.
4. Apply `noSplash` to `iconButtonTheme` and `textButtonTheme`.

## Check it

`dart analyze` exits clean.
`grep -c "NoSplash.splashFactory" lib/app/theme/app_theme.dart` -> 2 (or more).

## Don't touch

- Do not alter button sizes or background colors configured in `elevatedButtonTheme` and `outlinedButtonTheme`.
- Do not alter custom scale/opacity feedback animations in custom cards.

## STOP if

- Flutter SDK version deprecates `WidgetStateProperty` (use `WidgetStateProperty.all` as standard in Flutter 3.22+).

## When you're done

Tapping buttons, icons, or navigation items is instantaneous and clean, free from unwanted circular ripples or grey smudge overlays.

