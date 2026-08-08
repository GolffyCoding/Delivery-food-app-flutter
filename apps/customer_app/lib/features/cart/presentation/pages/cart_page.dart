import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:customer_app/features/checkout/presentation/pages/checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  static const String route = '/cart';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartLoaded>(
      builder: (context, state) {
        final items = state.items;

        if (items.isEmpty) {
          return Scaffold(
            appBar: const AppAppBar(title: 'My Cart', showBackButton: true),
            body: const EmptyStateView(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add items from a restaurant to get started',
            ),
          );
        }

        return Scaffold(
          appBar: const AppAppBar(title: 'My Cart', showBackButton: true),
          body: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppNetworkImage(imageUrl: item.food.imageUrl, width: 70, height: 70, borderRadius: AppRadius.mdBorder),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.food.name, style: context.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('\$${item.food.currentPrice.toStringAsFixed(2)}', style: context.textTheme.labelLarge?.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
                              const SizedBox(height: AppSpacing.sm),
                              AppQuantityStepper(
                                value: item.quantity,
                                // 0 is a valid target here on purpose: the bloc
                                // treats decrementing to 0 as "remove this item".
                                min: 0,
                                onChanged: (qty) => context.read<CartBloc>().add(CartUpdateQuantity(item.food.id, qty)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => context.read<CartBloc>().add(CartRemoveItem(item.food.id)),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  boxShadow: AppShadows.mdList,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PriceRow(label: 'Subtotal', value: '\$${state.subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _PriceRow(label: 'Delivery Fee', value: state.deliveryFee == 0 ? 'Free' : '\$${state.deliveryFee.toStringAsFixed(2)}'),
                      const Divider(height: 24),
                      _PriceRow(label: 'Total', value: '\$${state.total.toStringAsFixed(2)}', isTotal: true),
                      const SizedBox(height: 16),
                      AppButton(text: 'Proceed to Checkout', onPressed: () => context.push(CheckoutPage.route)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _PriceRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.textTheme.bodyLarge?.copyWith(color: isTotal ? context.colorScheme.onSurface : context.colorScheme.outline)),
        Text(value, style: context.textTheme.titleMedium?.copyWith(fontWeight: isTotal ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }
}
