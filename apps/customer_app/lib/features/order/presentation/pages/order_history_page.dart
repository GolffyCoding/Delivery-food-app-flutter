import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/data/order/order_repository.dart';
import 'package:customer_app/di/injection.dart';
import 'package:customer_app/domain/models/order_model.dart';
import 'package:customer_app/features/order/presentation/pages/order_tracking_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});
  static const String route = '/orders';

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Future<Result<List<OrderModel>, Failure>> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<OrderRepository>().listMyOrders();
  }

  void _reload() {
    setState(() => _future = getIt<OrderRepository>().listMyOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'My Orders'),
      body: FutureBuilder<Result<List<OrderModel>, Failure>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const AppLoadingIndicator();

          return snapshot.data!.when(
            success: (orders) {
              if (orders.isEmpty) {
                return const EmptyStateView(icon: Icons.receipt_long_outlined, title: 'No orders yet', subtitle: 'Your order history will appear here');
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final isFinal = order.status == 'delivered' || order.status == 'completed';
                  return AppCard(
                    onTap: () => context.push('${OrderTrackingPage.route}/${order.id}'),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppNetworkImage(imageUrl: order.restaurantImage, width: 60, height: 60, borderRadius: AppRadius.mdBorder),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.restaurantName, style: context.textTheme.titleSmall),
                              const SizedBox(height: 4),
                              Text('${order.items.length} items  •  \$${order.total.toStringAsFixed(2)}', style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.outline)),
                              const SizedBox(height: AppSpacing.sm),
                              AppBadge(label: order.statusLabel, color: isFinal ? AppColors.success : AppColors.info),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(order.createdAt.timeAgo, style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.outline)),
                            const SizedBox(height: 8),
                            if (!isFinal)
                              FilledButton.tonal(onPressed: () => context.push('${OrderTrackingPage.route}/${order.id}'), child: const Text('Track'))
                            else
                              AppTextButton(text: 'Reorder', onPressed: () {}),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            failure: (failure) => ErrorView(failure: failure, onRetry: _reload),
          );
        },
      ),
    );
  }
}
