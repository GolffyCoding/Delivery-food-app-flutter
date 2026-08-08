import 'package:flutter/material.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';

/// Reusable card widget with consistent styling.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: color ?? context.colorScheme.surface,
        borderRadius: borderRadius ?? AppRadius.lgBorder,
        border: border ?? Border.all(color: context.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: AppShadows.smList,
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? const EdgeInsets.only(bottom: AppSpacing.md),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? AppRadius.lgBorder,
            child: card,
          ),
        ),
      );
    }

    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: AppSpacing.md),
      child: card,
    );
  }
}
