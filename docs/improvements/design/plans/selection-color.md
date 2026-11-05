# Fix: Input text selection uses default colors instead of FitSync brand lime green

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/selection-color
- **Needs new dependency**: none

## Why

When users select or highlight text in input fields, Flutter displays the default teal/blue selection and cursor colors. In a dark themed app with neon lime green accents, this clashes with the brand identity. Adding `textSelectionTheme` aligns text cursors and highlights with FitSync's visual language.

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

Add `textSelectionTheme` to `ThemeData` in `lib/app/theme/app_theme.dart`:

```dart
// target
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: AppColors.primary.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.primary,
        cursorColor: AppColors.primary,
      ),
```

## Steps

1. Open `lib/app/theme/app_theme.dart`.
2. Inside `static ThemeData get darkTheme`, add `textSelectionTheme` specifying `AppColors.primary.withValues(alpha: 0.3)` for selection and `AppColors.primary` for handles and cursor.

## Check it

`dart analyze` exits clean.
`grep -c "textSelectionTheme" lib/app/theme/app_theme.dart` -> 1.

## Don't touch

- Do not change existing colors in `AppColors`.
- Do not modify input border styles or field heights in `inputDecorationTheme`.
- No new dependencies.

## STOP if

- The code in `lib/app/theme/app_theme.dart` does not match the excerpt.
- `dart analyze` reports syntax errors after adding the theme.

## When you're done

Text selection highlight and handles in all text fields (such as search, login, profile edit, and workout logging) now glow with FitSync's lime green accent with clean opacity instead of default blue. Open any search field or form to see it.

