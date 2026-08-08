import 'package:flutter/material.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/src/widgets/app_button.dart';

/// Title (+ optional subtitle) with an optional "See All" action, used above
/// horizontal/vertical listing sections across the home feed, restaurant
/// detail page, etc. Consolidates what used to be copy-pasted per screen.
class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.seeAllLabel = 'See All',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: context.textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.outline)),
                ],
              ],
            ),
          ),
          if (onSeeAll != null) AppTextButton(text: seeAllLabel, onPressed: onSeeAll),
        ],
      ),
    );
  }
}
