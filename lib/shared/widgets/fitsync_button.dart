import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum FitSyncButtonVariant { primary, secondary, outline, text }

class FitSyncButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final FitSyncButtonVariant variant;
  final double? width;
  final double height;

  const FitSyncButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = FitSyncButtonVariant.primary,
    this.width = double.infinity,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getBackgroundColor() {
      if (onPressed == null || isLoading) {
        return AppColors.surfaceHighlight;
      }
      switch (variant) {
        case FitSyncButtonVariant.primary:
          return AppColors.primary;
        case FitSyncButtonVariant.secondary:
          return AppColors.surfaceElevated;
        case FitSyncButtonVariant.outline:
        case FitSyncButtonVariant.text:
          return Colors.transparent;
      }
    }

    Color getForegroundColor() {
      if (onPressed == null || isLoading) {
        return AppColors.textMuted;
      }
      switch (variant) {
        case FitSyncButtonVariant.primary:
          return AppColors.textOnPrimary;
        case FitSyncButtonVariant.secondary:
        case FitSyncButtonVariant.outline:
          return AppColors.textPrimary;
        case FitSyncButtonVariant.text:
          return AppColors.primary;
      }
    }

    BorderSide? getBorderSide() {
      if (variant == FitSyncButtonVariant.outline) {
        return BorderSide(
          color: (onPressed == null || isLoading)
              ? AppColors.border
              : AppColors.borderFocused.withValues(alpha: 0.6),
          width: 1.2,
        );
      }
      return null;
    }

    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(getForegroundColor()),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: getForegroundColor(),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: getBackgroundColor(),
        shape: getBorderSide() != null
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: getBorderSide()!,
              )
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isLoading ? null : onPressed,
          child: Center(child: content),
        ),
      ),
    );
  }
}
