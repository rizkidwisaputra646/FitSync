import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class FitSyncCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? borderColor;

  const FitSyncCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.isSelected = false,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(
      color: isSelected
          ? AppColors.primary
          : (borderColor ?? AppColors.border),
      width: isSelected ? 1.8 : 1.0,
    );

    return Material(
      color: isSelected
          ? AppColors.primaryContainer.withValues(alpha: 0.35)
          : (backgroundColor ?? AppColors.surfaceElevated),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: border,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class FitSyncBadge extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final Widget? icon;

  const FitSyncBadge({
    super.key,
    required this.text,
    this.textColor,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceHighlight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
