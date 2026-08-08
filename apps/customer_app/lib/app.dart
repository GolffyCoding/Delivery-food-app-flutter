import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:customer_app/di/injection.dart';
import 'package:customer_app/router/app_router.dart';
import 'package:customer_app/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:customer_app/features/theme/presentation/bloc/theme_event.dart';
import 'package:customer_app/features/theme/presentation/bloc/theme_state.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:customer_app/features/cart/presentation/bloc/cart_bloc.dart';

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ThemeBloc>()..add(const ThemeLoad())),
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<CartBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'OpenDelivery',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeState.themeMode.toThemeMode,
            routerConfig: getIt<AppRouter>().config,
          );
        },
      ),
    );
  }
}
