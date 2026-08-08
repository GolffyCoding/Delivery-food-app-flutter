import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:driver_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:driver_app/features/auth/presentation/pages/auth_page.dart';
import 'package:driver_app/features/auth/presentation/pages/splash_page.dart';
import 'package:driver_app/features/home/pages/driver_home_page.dart';
import 'package:driver_app/features/incoming_order/pages/incoming_order_page.dart';
import 'package:driver_app/features/active_delivery/pages/active_delivery_page.dart';
import 'package:driver_app/features/earnings/pages/earnings_page.dart';
import 'package:driver_app/features/profile/pages/driver_profile_page.dart';
import 'package:driver_app/router/main_shell.dart';

class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter _router;

  AppRouter(this.authBloc) {
    _router = GoRouter(
      initialLocation: SplashPage.route,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthRoute = state.matchedLocation == AuthPage.route || state.matchedLocation == SplashPage.route;

        if (authState is AuthAuthenticated && isAuthRoute) return DriverHomePage.route;
        if (authState is AuthUnauthenticated && !isAuthRoute) return AuthPage.route;
        return null;
      },
      routes: [
        GoRoute(path: SplashPage.route, builder: (context, state) => const SplashPage()),
        GoRoute(path: AuthPage.route, builder: (context, state) => const AuthPage()),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => DriverMainShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: DriverHomePage.route, builder: (context, state) => const DriverHomePage())]),
            StatefulShellBranch(routes: [GoRoute(path: EarningsPage.route, builder: (context, state) => const EarningsPage())]),
            StatefulShellBranch(routes: [GoRoute(path: DriverProfilePage.route, builder: (context, state) => const DriverProfilePage())]),
          ],
        ),
        GoRoute(
          path: IncomingOrderPage.route,
          builder: (context, state) => IncomingOrderPage(orderData: state.extra as Map<String, dynamic>? ?? const {}),
        ),
        GoRoute(
          path: '${ActiveDeliveryPage.route}/:id',
          builder: (context, state) => ActiveDeliveryPage(orderId: state.pathParameters['id']!),
        ),
      ],
    );
  }

  GoRouter get config => _router;
}

/// Bridges a BLoC stream to a [Listenable] so GoRouter can re-evaluate
/// `redirect` whenever auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  late final Stream<dynamic> _stream;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _stream = stream.asBroadcastStream();
    _stream.listen((_) => notifyListeners());
  }
}
