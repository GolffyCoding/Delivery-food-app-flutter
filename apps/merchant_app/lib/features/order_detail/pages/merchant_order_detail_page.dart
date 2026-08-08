import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:opendelivery_state_machine/opendelivery_state_machine.dart';
import 'package:merchant_app/features/dashboard/bloc/merchant_order_bloc.dart';

class MerchantOrderDetailPage extends StatelessWidget {
  final String orderId;
  final MerchantOrderBloc bloc;
  const MerchantOrderDetailPage({super.key, required this.orderId, required this.bloc});
  static const String route = '/merchant-order';

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: const AppAppBar(title: 'Order Details', showBackButton: true),
        body: BlocBuilder<MerchantOrderBloc, MerchantOrderState>(
          builder: (context, state) {
            final allOrders = [...state.newOrders, ...state.preparingOrders, ...state.readyOrders];
            KanbanOrder? order;
            for (final o in allOrders) {
              if (o.id == orderId) {
                order = o;
                break;
              }
            }
            final currentState = order?.state ?? const PendingState();
            final items = order?.items ?? const [];
            final total = order?.total ?? 0;

            return SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order #$orderId', style: context.textTheme.titleMedium),
                        const Divider(height: 24),
                        if (items.isEmpty)
                          Text('No item details available', style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.outline))
                        else
                          for (final item in items)
                            _ItemRow(
                              name: '${item.quantity}x ${item.name}',
                              price: '\$${item.subtotal.toStringAsFixed(2)}',
                            ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ..._getActionsForState(context, currentState, orderId),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _getActionsForState(BuildContext context, OrderState state, String orderId) {
    // We strictly only ever show the valid next transitions for the current
    // state — the UI itself can never trigger an invalid jump.
    if (state is PendingState) {
      return [
        AppButton(text: 'Accept Order', onPressed: () => _dispatch(context, orderId, const AcceptEvent(), 'accepted')),
        const SizedBox(height: AppSpacing.md),
        AppOutlinedButton(text: 'Reject Order', onPressed: () => _dispatch(context, orderId, const CancelEvent(), 'cancelled')),
      ];
    }
    if (state is AcceptedState) {
      return [AppButton(text: 'Start Preparing', onPressed: () => _dispatch(context, orderId, const StartPreparingEvent(), 'preparing'))];
    }
    if (state is PreparingState) {
      return [AppButton(text: 'Mark as Ready for Pickup', onPressed: () => _dispatch(context, orderId, const FinishPreparingEvent(), 'ready'))];
    }
    if (state is ReadyState) {
      return [const AppButton(text: 'Waiting for Driver...', onPressed: null)];
    }
    return [const AppButton(text: 'Order Finished', onPressed: null)];
  }

  void _dispatch(BuildContext context, String orderId, OrderEvent event, String backendStatus) {
    context.read<MerchantOrderBloc>().add(UpdateLocalOrderStatus(orderId, event, backendStatus));
  }
}

class _ItemRow extends StatelessWidget {
  final String name;
  final String price;
  const _ItemRow({required this.name, required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: context.textTheme.bodyMedium),
          Text(price, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
