# Fix: Reselecting the active bottom nav tab does nothing instead of scrolling to top

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/bottom-nav-reselect
- **Needs new dependency**: none

## Why

Tapping the bottom navigation bar item you are already viewing should smoothly scroll that screen back to the top. Native mobile users expect this behavior, and without it, they must manually swipe repeatedly up long lists to return to the header or search bar.

## Where

In `lib/features/dashboard/screens/dashboard_screen.dart:77`:

```dart
// lib/features/dashboard/screens/dashboard_screen.dart:77 — current
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
```

## The fix

Maintain a `ScrollController` for the dashboard tab and trigger `animateTo(0)` when `index == _currentIndex`:

```dart
// target
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == _currentIndex) {
                  if (_dashboardScrollController.hasClients) {
                    _dashboardScrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  }
                  return;
                }
                setState(() => _currentIndex = index);
              },
              type: BottomNavigationBarType.fixed,
```

And attach `_dashboardScrollController` to the dashboard's `SingleChildScrollView`.

## Steps

1. In `_DashboardScreenState`, instantiate `final ScrollController _dashboardScrollController = ScrollController();` and dispose it in `dispose()`.
2. Attach `controller: _dashboardScrollController` to the `SingleChildScrollView` on the home dashboard view.
3. In `BottomNavigationBar.onTap`, add reselection branch: if `index == _currentIndex`, animate the corresponding scroll controller to top.

## Check it

`dart analyze` exits clean.
`grep -c "_dashboardScrollController.animateTo" lib/features/dashboard/screens/dashboard_screen.dart` -> 1.

## Don't touch

- Do not alter tab index definitions or destination screens.
- Do not remove existing tab icons or labels.

## STOP if

- Scroll controller is accessed after disposal.

## When you're done

Tapping the active "Home" or workout tab a second time immediately glides the view back up to the top.

