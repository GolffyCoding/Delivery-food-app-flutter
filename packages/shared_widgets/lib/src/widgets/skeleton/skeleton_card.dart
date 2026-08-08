import 'package:flutter/material.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';

/// Skeleton placeholder for a restaurant card.
class SkeletonRestaurantCard extends StatelessWidget {
  const SkeletonRestaurantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 180, decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: AppRadius.smBorder)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 12, width: 120, decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: AppRadius.smBorder)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 12, width: 80, decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: AppRadius.smBorder)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder for a food item card.
class SkeletonFoodCard extends StatelessWidget {
  const SkeletonFoodCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: AppRadius.mdBorder)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 150, decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: AppRadius.smBorder)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 10, width: 100, decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: AppRadius.smBorder)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 14, width: 60, decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: AppRadius.smBorder)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
