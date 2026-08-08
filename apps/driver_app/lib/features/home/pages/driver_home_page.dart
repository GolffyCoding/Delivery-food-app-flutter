import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:driver_app/di/injection.dart';
import 'package:driver_app/features/home/bloc/driver_online_bloc.dart';
import 'package:driver_app/features/incoming_order/pages/incoming_order_page.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});
  static const String route = '/driver-home';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DriverOnlineBloc>(),
      child: BlocListener<DriverOnlineBloc, DriverOnlineState>(
        listenWhen: (previous, current) => current.incomingOrder != null && previous.incomingOrder != current.incomingOrder,
        listener: (context, state) {
          context.push(IncomingOrderPage.route, extra: state.incomingOrder);
        },
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                color: AppColors.neutral100,
                child: const Center(child: Text('Driver Map View', style: TextStyle(color: AppColors.neutral500))),
              ),
              Positioned(
                top: AppSpacing.xl,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                child: BlocBuilder<DriverOnlineBloc, DriverOnlineState>(
                  builder: (context, state) {
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.lgBorder, boxShadow: AppShadows.mdList),
                      child: Row(
                        children: [
                          Icon(Icons.delivery_dining, color: state.isOnline ? AppColors.brandPrimary : AppColors.neutral400),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(state.isOnline ? 'You are Online' : 'You are Offline', style: context.textTheme.titleSmall),
                                Text(
                                  state.isOnline ? 'Waiting for orders...' : 'Go online to start earning',
                                  style: context.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: state.isOnline,
                            onChanged: (_) => context.read<DriverOnlineBloc>().add(ToggleOnline()),
                            activeColor: AppColors.brandPrimary,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
