# Fix: Network images pop in abruptly with no transition or subtle placeholder

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/smooth-image-loading
- **Needs new dependency**: `image_fade: ^0.7.0` (for smooth cross-fade, placeholder, and silent error states)

## Why

Images in Flutter load with no transition, no placeholder, and no graceful error state. They just snap onto the screen when bytes finish downloading. A gentle cross-fade with a dark surface placeholder makes image loading calm, sporty, and premium without jarring layout pops.

## Where

1. `pubspec.yaml:47`
2. `lib/features/exercises/screens/exercise_library_screen.dart:475` (exercise thumbnail)
3. `lib/features/exercises/screens/exercise_detail_screen.dart` (instruction preview images)

```dart
// lib/features/exercises/screens/exercise_library_screen.dart:475 — current
ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: Image.network(
    exercise.gifUrl,
    width: 60,
    height: 60,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => Container(
      width: 60,
      height: 60,
      color: AppColors.surfaceElevated,
      child: const Icon(Icons.fitness_center, color: AppColors.textMuted, size: 24),
    ),
  ),
)
```

## The fix

Use `ImageFade` with FitSync's dark surface placeholder:

```dart
// target
ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: ImageFade(
    image: NetworkImage(exercise.gifUrl),
    width: 60,
    height: 60,
    fit: BoxFit.cover,
    duration: const Duration(milliseconds: 300),
    placeholder: Container(
      width: 60,
      height: 60,
      color: AppColors.surfaceElevated,
    ),
    errorBuilder: (context, exception) => Container(
      width: 60,
      height: 60,
      color: AppColors.surfaceElevated,
      child: const Icon(Icons.fitness_center, color: AppColors.textMuted, size: 20),
    ),
  ),
)
```

## Steps

1. Add `image_fade: ^0.7.0` to `pubspec.yaml` under dependencies and run `flutter pub get`.
2. In `lib/features/exercises/screens/exercise_library_screen.dart`, wrap network image loads with `ImageFade`.
3. Provide a placeholder container matching `AppColors.surfaceElevated` and a subtle icon failure state.

## Check it

`dart analyze` exits clean.
`grep -c "ImageFade" lib/features/exercises/screens/exercise_library_screen.dart` -> 1.

## Don't touch

- Do not modify existing image aspect ratios or card bounding boxes.
- On active workout screen, keep the GIF live playback untouched.

## STOP if

- `flutter pub get` fails or conflicts with SDK constraints.
- Image URLs break or do not resolve.

## When you're done

Exercise thumbnails and network visuals fade smoothly into view against the dark theme instead of flickering or popping in suddenly.

