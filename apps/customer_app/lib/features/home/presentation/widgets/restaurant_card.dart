import 'package:flutter/material.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/domain/models/restaurant_model.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const RestaurantCard({super.key, required this.restaurant, this.onTap, this.margin});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AppNetworkImage(
                imageUrl: restaurant.imageUrl,
                height: 160,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              if (!restaurant.isOpen)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                    child: Center(child: Text('Closed', style: context.textTheme.titleMedium?.copyWith(color: Colors.white))),
                  ),
                ),
              if (restaurant.deliveryFee == 0)
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: AppRadius.smBorder),
                    child: Text('Free Delivery', style: context.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(restaurant.name, style: context.textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.starFilled.withValues(alpha: 0.1), borderRadius: AppRadius.smBorder),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.starFilled, size: 16),
                          const SizedBox(width: 2),
                          Text(restaurant.rating.toString(), style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(restaurant.cuisine, style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.outline)),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 14, color: context.colorScheme.outline),
                    const SizedBox(width: 4),
                    Text('${restaurant.deliveryTime} min', style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.outline)),
                    const SizedBox(width: AppSpacing.md),
                    Icon(Icons.delivery_dining_outlined, size: 14, color: context.colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.deliveryFee == 0 ? 'Free' : '\$${restaurant.deliveryFee.toStringAsFixed(2)}',
                      style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
