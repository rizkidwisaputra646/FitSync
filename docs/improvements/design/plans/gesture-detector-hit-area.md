# Fix: Taps on row padding and gaps between icons and text do nothing

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/gesture-detector-hit-area
- **Needs new dependency**: none

## Why

By default, `GestureDetector` only receives taps directly on painted pixels of its child widget. In workout set rows, dashboard action cards, and membership payment selectors, taps landing in padding gaps or transparent container areas fail to register, frustrating users when fast taps miss. Adding `behavior: HitTestBehavior.opaque` makes the entire bounding box receptive to touches.

## Where

1. `lib/features/dashboard/screens/dashboard_screen.dart:169` (profile avatar button in header)
2. `lib/features/dashboard/screens/dashboard_screen.dart:284` (action cards)
3. `lib/features/workout/widgets/set_tracker_row.dart:217` (set completion checkbox container)
4. `lib/features/membership/widgets/plan_purchase_modal.dart:148` (payment method selector rows)

```dart
// lib/features/dashboard/screens/dashboard_screen.dart:169 — current
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 4),
                child: Container(
```

## The fix

Add `behavior: HitTestBehavior.opaque`:

```dart
// target
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _currentIndex = 4),
                child: Container(
```

## Steps

1. In `lib/features/dashboard/screens/dashboard_screen.dart`, add `behavior: HitTestBehavior.opaque` to the header profile GestureDetector and workout action cards.
2. In `lib/features/workout/widgets/set_tracker_row.dart`, add `behavior: HitTestBehavior.opaque` to the set completion GestureDetector.
3. In `lib/features/membership/widgets/plan_purchase_modal.dart`, add `behavior: HitTestBehavior.opaque` to payment method selection rows.

## Check it

`dart analyze` exits clean.
`grep -c "behavior: HitTestBehavior.opaque" lib/features/dashboard/screens/dashboard_screen.dart` -> 2 (or more).
`grep -c "behavior: HitTestBehavior.opaque" lib/features/workout/widgets/set_tracker_row.dart` -> 1.

## Don't touch

- Do not change touch feedback animations.
- Do not use `translucent` unless two overlapping gestures specifically need to fire simultaneously.

## STOP if

- A GestureDetector wraps a nested scrolling widget where hit testing should not be intercepted.

## When you're done

All interactive cards, checkboxes, and avatar taps trigger reliably across their full container footprint, even when tapping outer margins or text gaps.

