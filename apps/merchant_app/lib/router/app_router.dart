import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merchant_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:merchant_app/features/auth/presentation/pages/auth_page.dart';
import 'package:merchant_app/features/auth/presentation/pages/splash_page.dart';
import 'package:merchant_app/features/restaurant_setup/pages/create_restaurant_page.dart';
import 'package:merchant_app/features/dashboard/pages/merchant_home_page.dart';
import 'package:merchant_app/features/dashboard/bloc/merchant_order_bloc.dart';
import 'package:merchant_app/features/menu/pages/menu_management_page.dart';
import 'package:merchant_app/features/sales/pages/sales_report_page.dart';
import 'package:merchant_app/features/profile/pages/merchant_profile_page.dart';
import 'package:merchant_app/features/order_detail/pages/merchant_order_detail_page.dart';
import 'package:merchant_app/features/reviews/pages/merchant_reviews_page.dart';
import 'package:merchant_app/router/main_shell.dart';

class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter _router;

  AppRouter(this.authBloc) {
    _router = GoRouter(
      initialLocation: SplashPage.route,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isPreShellRoute = state.matchedLocation == AuthPage.route ||
            state.matchedLocation == SplashPage.route ||
            state.matchedLocation == CreateRestaurantPage.route;

        if (authState is AuthUnauthenticated && !isPreShellRoute) return AuthPage.route;
        return null;
      },
      routes: [
        GoRoute(path: SplashPage.route, builder: (context, state) => const SplashPage()),
        GoRoute(path: AuthPage.route, builder: (context, state) => const AuthPage()),
        GoRoute(path: CreateRestaurantPage.route, builder: (context, state) => const CreateRestaurantPage()),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => MerchantMainShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: MerchantHomePage.route, builder: (context, state) => const MerchantHomePage())]),
            StatefulShellBranch(routes: [GoRoute(path: MenuManagementPage.route, builder: (context, state) => const MenuManagementPage())]),
            StatefulShellBranch(routes: [GoRoute(path: SalesReportPage.route, builder: (context, state) => const SalesReportPage())]),
            StatefulShellBranch(routes: [GoRoute(path: MerchantProfilePage.route, builder: (context, state) => const MerchantProfilePage())]),
          ],
        ),
        GoRoute(
          path: '${MerchantOrderDetailPage.route}/:id',
          builder: (context, state) => MerchantOrderDetailPage(
            orderId: state.pathParameters['id']!,
            bloc: state.extra as MerchantOrderBloc,
          ),
        ),
        GoRoute(
          path: MerchantReviewsPage.route,
          builder: (context, state) => MerchantReviewsPage(restaurantId: state.extra as String),
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
