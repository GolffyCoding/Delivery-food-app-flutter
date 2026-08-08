import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:merchant_app/di/injection.dart';
import 'package:merchant_app/domain/models/menu_item_model.dart';
import 'package:merchant_app/features/menu/bloc/menu_bloc.dart';
import 'package:merchant_app/features/menu/widgets/add_menu_item_sheet.dart';
import 'package:merchant_app/features/restaurant_setup/bloc/restaurant_session_bloc.dart';

class MenuManagementPage extends StatelessWidget {
  const MenuManagementPage({super.key});
  static const String route = '/menu';

  @override
  Widget build(BuildContext context) {
    final session = context.watch<RestaurantSessionBloc>().state;
    final restaurantId = session is RestaurantSessionReady ? session.restaurantId : '';

    return BlocProvider(
      create: (_) => getIt<MenuBloc>()..add(LoadMenu(restaurantId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menu Management'),
          actions: [
            BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) {
                if (state.lowStockItems.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                  onPressed: () => _showLowStockDialog(context, state.lowStockItems),
                );
              },
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => BlocProvider.value(
                value: context.read<MenuBloc>(),
                child: AddMenuItemSheet(restaurantId: restaurantId),
              ),
            ),
            child: const Icon(Icons.add),
          ),
        ),
        body: BlocBuilder<MenuBloc, MenuState>(
          builder: (context, state) {
            if (state.isLoading) return const AppLoadingIndicator();

            return ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(item.name, style: context.textTheme.titleSmall)),
                                if (item.isOutOfStock) const AppBadge(label: 'Out of Stock', color: AppColors.error),
                                if (item.isLowStock && !item.isOutOfStock) const AppBadge(label: 'Low Stock', color: AppColors.warning),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.outline),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Text('\$${item.price.toStringAsFixed(2)}', style: context.textTheme.labelLarge?.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
                                const SizedBox(width: AppSpacing.sm),
                                Text('Stock: ${item.stockCount}', style: context.textTheme.labelSmall?.copyWith(color: item.isLowStock ? AppColors.error : AppColors.neutral600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: item.isAvailable,
                        onChanged: item.isOutOfStock ? null : (_) => context.read<MenuBloc>().add(ToggleAvailability(item.id)),
                        activeColor: AppColors.brandPrimary,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showLowStockDialog(BuildContext context, List<MenuItemModel> lowStockItems) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: AppColors.error), SizedBox(width: 8), Text('Inventory Alert')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: lowStockItems
              .map((item) => ListTile(
                    dense: true,
                    title: Text(item.name, style: const TextStyle(fontSize: 14)),
                    trailing: Text(
                      '${item.stockCount} left',
                      style: TextStyle(color: item.isOutOfStock ? AppColors.error : AppColors.warning, fontWeight: FontWeight.bold),
                    ),
                  ))
              .toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Dismiss'))],
      ),
    );
  }
}
