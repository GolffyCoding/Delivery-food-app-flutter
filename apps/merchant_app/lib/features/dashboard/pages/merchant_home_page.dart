import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_state_machine/opendelivery_state_machine.dart';
import 'package:merchant_app/di/injection.dart';
import 'package:merchant_app/features/dashboard/bloc/merchant_order_bloc.dart';
import 'package:merchant_app/features/dashboard/widgets/order_card.dart';
import 'package:merchant_app/features/order_detail/pages/merchant_order_detail_page.dart';
import 'package:merchant_app/features/restaurant_setup/bloc/restaurant_session_bloc.dart';

class MerchantHomePage extends StatelessWidget {
  const MerchantHomePage({super.key});
  static const String route = '/merchant-home';

  @override
  Widget build(BuildContext context) {
    final session = context.watch<RestaurantSessionBloc>().state;
    final restaurantId = session is RestaurantSessionReady ? session.restaurantId : '';

    return BlocProvider(
      create: (_) => getIt<MerchantOrderBloc>()..add(LoadOrders(restaurantId)),
      child: const MerchantHomeView(),
    );
  }
}

class MerchantHomeView extends StatelessWidget {
  const MerchantHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        title: const Text('Kitchen Display'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          BlocBuilder<RestaurantSessionBloc, RestaurantSessionState>(
            builder: (context, session) {
              if (session is! RestaurantSessionReady) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Row(
                  children: [
                    Text(session.isOpen ? 'Open' : 'Closed',
                        style: TextStyle(fontWeight: FontWeight.bold, color: session.isOpen ? AppColors.success : AppColors.error)),
                    Switch(
                      value: session.isOpen,
                      onChanged: session.isTogglingOpen
                          ? null
                          : (_) => context.read<RestaurantSessionBloc>().add(ToggleOpenStatus()),
                      activeThumbColor: AppColors.success,
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Chip(
              avatar: const Icon(Icons.wifi, size: 16, color: AppColors.brandPrimary),
              label: const Text('Live', style: TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.brandPrimary.withValues(alpha: 0.1),
              side: BorderSide.none,
            ),
          ),
        ],
      ),
      body: BlocConsumer<MerchantOrderBloc, MerchantOrderState>(
        listener: (context, state) {
          if (state.actionError != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.actionError!)));
          }
        },
        builder: (context, state) {
          final bloc = context.read<MerchantOrderBloc>();
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KanbanColumn(
                title: 'NEW ORDERS',
                color: AppColors.warning,
                orders: state.newOrders,
                onAction: (orderId) => bloc.add(UpdateLocalOrderStatus(orderId, const AcceptEvent(), 'accepted')),
                onTapOrder: (orderId) => _openDetail(context, bloc, orderId),
                actionLabel: 'ACCEPT',
              ),
              _KanbanColumn(
                title: 'PREPARING',
                color: AppColors.info,
                orders: state.preparingOrders,
                onAction: (orderId) => bloc.add(UpdateLocalOrderStatus(orderId, const FinishPreparingEvent(), 'ready')),
                onTapOrder: (orderId) => _openDetail(context, bloc, orderId),
                actionLabel: 'READY',
              ),
              _KanbanColumn(
                title: 'READY FOR PICKUP',
                color: AppColors.success,
                orders: state.readyOrders,
                onAction: null,
                onTapOrder: (orderId) => _openDetail(context, bloc, orderId),
                actionLabel: 'WAITING FOR DRIVER',
              ),
            ],
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, MerchantOrderBloc bloc, String orderId) {
    context.push('${MerchantOrderDetailPage.route}/$orderId', extra: bloc);
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final Color color;
  final List<KanbanOrder> orders;
  final void Function(String orderId)? onAction;
  final void Function(String orderId) onTapOrder;
  final String actionLabel;

  const _KanbanColumn({
    required this.title,
    required this.color,
    required this.orders,
    required this.onAction,
    required this.onTapOrder,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.lgBorder, boxShadow: AppShadows.smList),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: context.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: color, borderRadius: AppRadius.fullBorder),
                    child: Text('${orders.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.sm),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _TimerWrapper(
                    child: OrderCard(
                      order: order,
                      onTap: () => onTapOrder(order.id),
                      onAction: onAction == null ? null : () => onAction!(order.id),
                      actionLabel: actionLabel,
                      accentColor: color,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rebuilds every second to keep the elapsed-time badge live, without
/// forcing the BLoC to `emit` on a timer (which would rebuild every card).
class _TimerWrapper extends StatefulWidget {
  final Widget child;
  const _TimerWrapper({required this.child});

  @override
  State<_TimerWrapper> createState() => _TimerWrapperState();
}

class _TimerWrapperState extends State<_TimerWrapper> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
