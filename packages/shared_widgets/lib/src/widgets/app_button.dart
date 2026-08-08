import 'package:flutter/material.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_core/opendelivery_core.dart';

/// Primary app button with loading state support.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonStyle? style;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.style,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ??
        FilledButton.styleFrom(
          minimumSize: isFullWidth ? const Size(double.infinity, 48) : null,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          padding: padding ?? AppSpacing.buttonPadding,
        );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: effectiveStyle,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [icon!, const SizedBox(width: AppSpacing.sm), Text(text)],
                  )
                : Text(text),
      ),
    );
  }
}

/// Outlined variant of [AppButton].
class AppOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;

  const AppOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: isFullWidth ? const Size(double.infinity, 48) : null,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          padding: AppSpacing.buttonPadding,
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [icon!, const SizedBox(width: AppSpacing.sm), Text(text)],
                  )
                : Text(text),
      ),
    );
  }
}

/// Text variant of [AppButton].
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final FontWeight? fontWeight;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? context.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(text, style: TextStyle(fontWeight: fontWeight ?? FontWeight.w600)),
    );
  }
}
