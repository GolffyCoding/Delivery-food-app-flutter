import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:driver_app/di/injection.dart';
import 'package:driver_app/features/incoming_order/bloc/incoming_order_bloc.dart';
import 'package:driver_app/features/incoming_order/bloc/incoming_order_event.dart';
import 'package:driver_app/features/incoming_order/bloc/incoming_order_state.dart';
import 'package:driver_app/features/active_delivery/pages/active_delivery_page.dart';

class IncomingOrderPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  const IncomingOrderPage({super.key, required this.orderData});
  static const String route = '/incoming-order';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<IncomingOrderBloc>()..add(StartCountdown(orderData)),
      child: BlocListener<IncomingOrderBloc, IncomingOrderState>(
        listener: (context, state) {
          if (state is IncomingOrderAccepted) {
            context.go('${ActiveDeliveryPage.route}/${state.orderId}');
          } else if (state is IncomingOrderRejected) {
            if (context.canPop()) context.pop();
          }
        },
        child: BlocBuilder<IncomingOrderBloc, IncomingOrderState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.black54,
              body: Center(
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.xlBorder),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state is IncomingOrderCountdown)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: state.remainingSeconds / 15,
                                strokeWidth: 8,
                                backgroundColor: AppColors.neutral200,
                                valueColor: const AlwaysStoppedAnimation(AppColors.brandPrimary),
                              ),
                            ),
                            Text('${state.remainingSeconds}s', style: context.textTheme.headlineMedium),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('New Order!', style: context.textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Pickup: ${orderData['restaurant_name'] ?? 'Restaurant'}', style: context.textTheme.bodyLarge),
                      Text(
                        'Dropoff: ${orderData['customer_address'] ?? 'Customer Address'}',
                        style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.outline),
                      ),
                      Text(
                        'Earnings: \$${orderData['earnings'] ?? '5.00'}',
                        style: context.textTheme.titleMedium?.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: AppOutlinedButton(
                              text: 'Decline',
                              onPressed: () => context.read<IncomingOrderBloc>().add(RejectOrder(orderData['order_id'] as String? ?? '')),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: AppButton(
                              text: state is IncomingOrderLoading ? 'Accepting...' : 'Accept',
                              isLoading: state is IncomingOrderLoading,
                              onPressed: state is IncomingOrderLoading
                                  ? null
                                  : () => context.read<IncomingOrderBloc>().add(AcceptOrder(orderData['order_id'] as String? ?? '')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
