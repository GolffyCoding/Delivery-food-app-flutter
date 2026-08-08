import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:driver_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:driver_app/features/auth/presentation/pages/auth_page.dart';
import 'package:driver_app/features/home/pages/driver_home_page.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(DriverHomePage.route);
        } else if (state is AuthUnauthenticated) {
          context.go(AuthPage.route);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.brandPrimary,
        body: const Center(child: AppLoadingIndicator(color: Colors.white)),
      ),
    );
  }
}
