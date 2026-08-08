import 'package:flutter/material.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';

/// Full-screen error view with retry action.
class ErrorView extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  final String? customMessage;

  const ErrorView({super.key, required this.failure, this.onRetry, this.customMessage});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              customMessage ?? failure.message,
              style: context.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(text: 'Try Again', onPressed: onRetry, isFullWidth: false),
            ],
          ],
        ),
      ),
    );
  }
}
