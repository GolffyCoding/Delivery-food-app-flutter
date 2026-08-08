import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_app/di/injection.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:customer_app/features/auth/presentation/pages/login_page.dart';
import 'package:customer_app/features/auth/presentation/pages/register_page.dart';
import 'package:customer_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:customer_app/features/home/presentation/bloc/restaurant_bloc.dart';
import 'package:customer_app/features/home/presentation/pages/home_page.dart';
import 'package:customer_app/features/home/presentation/pages/restaurant_detail_page.dart';
import 'package:customer_app/features/home/presentation/pages/food_detail_page.dart';
import 'package:customer_app/domain/models/food_item_model.dart';
import 'package:customer_app/features/home/presentation/pages/search_page.dart';
import 'package:customer_app/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:customer_app/features/order/presentation/bloc/order_tracking_bloc.dart';
import 'package:customer_app/features/order/presentation/pages/order_tracking_page.dart';
import 'package:customer_app/features/order/presentation/pages/order_history_page.dart';
import 'package:customer_app/features/profile/presentation/pages/profile_page.dart';
import 'package:customer_app/features/profile/presentation/pages/settings_page.dart';
import 'package:customer_app/features/profile/presentation/pages/address_page.dart';
import 'package:customer_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:customer_app/features/profile/presentation/pages/favorites_page.dart';
import 'package:customer_app/features/splash/presentation/pages/splash_page.dart';
import 'package:customer_app/router/main_page.dart';

class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter _router;

  AppRouter(this.authBloc) {
    _router = GoRouter(
      initialLocation: SplashPage.route,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthRoute = state.matchedLocation == LoginPage.route ||
            state.matchedLocation == RegisterPage.route ||
            state.matchedLocation == SplashPage.route;

        if (authState is AuthAuthenticated && isAuthRoute) {
          return HomePage.route;
        }
        if (authState is AuthUnauthenticated && !isAuthRoute) {
          return LoginPage.route;
        }
        return null;
      },
      routes: [
        GoRoute(path: SplashPage.route, builder: (context, state) => const SplashPage()),
        GoRoute(path: LoginPage.route, builder: (context, state) => const LoginPage()),
        GoRoute(path: RegisterPage.route, builder: (context, state) => const RegisterPage()),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => MainPage(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: HomePage.route,
                builder: (context, state) => BlocProvider(
                  create: (_) => getIt<HomeBloc>()..add(const HomeLoad()),
                  child: const HomePage(),
                ),
              ),
            ]),
            StatefulShellBranch(routes: [GoRoute(path: SearchPage.route, builder: (context, state) => const SearchPage())]),
            StatefulShellBranch(routes: [GoRoute(path: OrderHistoryPage.route, builder: (context, state) => const OrderHistoryPage())]),
            StatefulShellBranch(routes: [GoRoute(path: FavoritesPage.route, builder: (context, state) => const FavoritesPage())]),
            StatefulShellBranch(routes: [GoRoute(path: ProfilePage.route, builder: (context, state) => const ProfilePage())]),
          ],
        ),
        GoRoute(
          path: '${RestaurantDetailPage.route}/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider(
              create: (_) => getIt<RestaurantBloc>()..add(RestaurantLoad(id)),
              child: RestaurantDetailPage(restaurantId: id),
            );
          },
        ),
        GoRoute(
          path: FoodDetailPage.route,
          builder: (context, state) => FoodDetailPage(food: state.extra as FoodItemModel),
        ),
        GoRoute(path: CartPage.route, builder: (context, state) => const CartPage()),
        GoRoute(path: NotificationsPage.route, builder: (context, state) => const NotificationsPage()),
        GoRoute(path: CheckoutPage.route, builder: (context, state) => const CheckoutPage()),
        GoRoute(
          path: '${OrderTrackingPage.route}/:id',
          builder: (context, state) {
            final orderId = state.pathParameters['id']!;
            return BlocProvider(
              create: (_) => getIt<OrderTrackingBloc>()..add(OrderTrackingLoad(orderId)),
              child: OrderTrackingPage(orderId: orderId),
            );
          },
        ),
        GoRoute(path: SettingsPage.route, builder: (context, state) => const SettingsPage()),
        GoRoute(path: AddressPage.route, builder: (context, state) => const AddressPage()),
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
