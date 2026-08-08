import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:opendelivery_state_machine/opendelivery_state_machine.dart';
import 'package:driver_app/di/injection.dart';
import 'package:driver_app/features/active_delivery/bloc/active_delivery_bloc.dart';

class ActiveDeliveryPage extends StatelessWidget {
  final String orderId;
  const ActiveDeliveryPage({super.key, required this.orderId});
  static const String route = '/active-delivery';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ActiveDeliveryBloc>()..add(LoadDelivery(orderId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Active Delivery'), automaticallyImplyLeading: false),
        body: BlocBuilder<ActiveDeliveryBloc, ActiveDeliveryState>(
          builder: (context, state) {
            final isPickedUp = state.status is PickedUpState;
            final isDelivering = state.status is DeliveringState;

            return Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: AppRadius.lgBorder),
                    child: Center(
                      child: Text('Navigate to Customer', style: context.textTheme.titleMedium),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: const BoxDecoration(color: Colors.white, boxShadow: AppShadows.mdList),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Status: ${_mapStateToText(state.status)}', style: context.textTheme.titleSmall),
                        const SizedBox(height: AppSpacing.lg),
                        if (isPickedUp)
                          AppButton(
                            text: 'Start Delivering',
                            onPressed: () => context.read<ActiveDeliveryBloc>().add(UpdateStatus(const StartDeliveringEvent(), 'delivering')),
                          )
                        else if (isDelivering)
                          AppButton(
                            text: 'Mark as Delivered',
                            onPressed: () => context.read<ActiveDeliveryBloc>().add(UpdateStatus(const DeliverEvent(), 'delivered')),
                          )
                        else if (state.status is DeliveredState)
                          const AppButton(text: 'Completed', onPressed: null),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _mapStateToText(OrderState state) {
    return switch (state) {
      PickedUpState() => 'Order Picked Up',
      DeliveringState() => 'Delivering to Customer',
      DeliveredState() => 'Delivery Completed',
      _ => 'Processing...',
    };
  }
}
