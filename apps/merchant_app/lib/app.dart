import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:merchant_app/di/injection.dart';
import 'package:merchant_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:merchant_app/features/restaurant_setup/bloc/restaurant_session_bloc.dart';
import 'package:merchant_app/router/app_router.dart';

class MerchantApp extends StatelessWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<RestaurantSessionBloc>()),
      ],
      child: MaterialApp.router(
        title: 'OpenDelivery Merchant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: getIt<AppRouter>().config,
      ),
    );
  }
}
