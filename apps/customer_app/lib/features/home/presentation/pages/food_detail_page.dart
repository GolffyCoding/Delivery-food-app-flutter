import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/domain/models/food_item_model.dart';
import 'package:customer_app/features/cart/presentation/bloc/cart_bloc.dart';

class FoodDetailPage extends StatelessWidget {
  final FoodItemModel food;
  const FoodDetailPage({super.key, required this.food});
  static const String route = '/food';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: AppNetworkImage(imageUrl: food.imageUrl, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(food.name, style: context.textTheme.headlineSmall)),
                      if (food.hasDiscount)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: AppRadius.smBorder),
                          child: Text(
                            '${((1 - (food.discountPrice! / food.price)) * 100).round()}% OFF',
                            style: context.textTheme.labelSmall?.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(food.description, style: context.textTheme.bodyLarge?.copyWith(height: 1.5, color: context.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      if (food.hasDiscount) ...[
                        Text('\$${food.price.toStringAsFixed(2)}', style: context.textTheme.titleMedium?.copyWith(decoration: TextDecoration.lineThrough, color: context.colorScheme.outline)),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text('\$${food.currentPrice.toStringAsFixed(2)}', style: context.textTheme.headlineMedium?.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            text: 'Add to Cart  •  \$${food.currentPrice.toStringAsFixed(2)}',
            onPressed: () {
              context.read<CartBloc>().add(CartAddItem(food));
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}
