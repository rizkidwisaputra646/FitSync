# Fix: Long vertical screens have no scroll indicator to show position or remaining content

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/scrollbars
- **Needs new dependency**: none

## Why

When scrolling through the 1,300+ exercises in the library, workout histories, or long administrative lists, users have no visual scrollbar indicator to see where they are in the list or how much content remains. Providing an app-wide scroll behavior ensures scrollbars appear consistently across mobile, web, and desktop.

## Where

In `lib/app/app.dart:15`:

```dart
// lib/app/app.dart:15 — current
    return MaterialApp(
      title: 'FitSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGateway(),
    );
```

## The fix

Create `AlwaysScrollbarBehavior` and pass it to `MaterialApp.scrollBehavior`:

```dart
// target
class AlwaysScrollbarBehavior extends MaterialScrollBehavior {
  const AlwaysScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(
      controller: details.controller,
      child: child,
    );
  }
}
```

And in `MaterialApp`:

```dart
    return MaterialApp(
      title: 'FitSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      scrollBehavior: const AlwaysScrollbarBehavior(),
      home: const AuthGateway(),
    );
```

## Steps

1. In `lib/app/app.dart`, define `class AlwaysScrollbarBehavior extends MaterialScrollBehavior`.
2. Add `scrollBehavior: const AlwaysScrollbarBehavior()` inside `MaterialApp`.

## Check it

`dart analyze` exits clean.
`grep -c "AlwaysScrollbarBehavior" lib/app/app.dart` -> 2.

## Don't touch

- Do not alter `AuthGateway` routing logic.
- Do not add manual conflicting `Scrollbar` widgets inside single-page tabs without controllers.

## STOP if

- Flutter web desktop scrollbars conflict with manual scrollbar widgets.

## When you're done

A sleek, responsive scroll indicator appears alongside vertical lists throughout the application, keeping users oriented on page depth.

