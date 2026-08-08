import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:merchant_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:merchant_app/features/auth/presentation/pages/auth_page.dart';
import 'package:merchant_app/features/restaurant_setup/bloc/restaurant_session_bloc.dart';
import 'package:merchant_app/features/restaurant_setup/pages/create_restaurant_page.dart';
import 'package:merchant_app/features/dashboard/pages/merchant_home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  static const String route = '/splash';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthCheckStatus());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.read<RestaurantSessionBloc>().add(CheckRestaurant());
            } else if (state is AuthUnauthenticated) {
              context.go(AuthPage.route);
            }
          },
        ),
        BlocListener<RestaurantSessionBloc, RestaurantSessionState>(
          listener: (context, state) {
            if (state is RestaurantSessionReady) {
              context.go(MerchantHomePage.route);
            } else if (state is RestaurantSessionNeedsSetup) {
              context.go(CreateRestaurantPage.route);
            }
          },
        ),
      ],
      child: const Scaffold(
        backgroundColor: AppColors.brandPrimary,
        body: Center(child: AppLoadingIndicator(color: Colors.white)),
      ),
    );
  }
}
