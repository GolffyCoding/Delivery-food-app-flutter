import 'package:get_it/get_it.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';
import 'package:customer_app/data/address/address_repository.dart';
import 'package:customer_app/data/restaurant/restaurant_remote_datasource.dart';
import 'package:customer_app/data/restaurant/restaurant_repository.dart';
import 'package:customer_app/data/coupon/coupon_remote_datasource.dart';
import 'package:customer_app/data/coupon/coupon_repository.dart';
import 'package:customer_app/data/notifications/notification_remote_datasource.dart';
import 'package:customer_app/data/notifications/notification_repository.dart';
import 'package:customer_app/data/order/order_remote_datasource.dart';
import 'package:customer_app/data/order/order_repository.dart';
import 'package:customer_app/data/review/review_remote_datasource.dart';
import 'package:customer_app/data/review/review_repository.dart';
import 'package:customer_app/data/tracking/eta_repository.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:customer_app/features/auth/presentation/bloc/login_bloc.dart';
import 'package:customer_app/features/auth/presentation/bloc/register_bloc.dart';
import 'package:customer_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:customer_app/features/home/presentation/bloc/restaurant_bloc.dart';
import 'package:customer_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:customer_app/features/order/presentation/bloc/order_tracking_bloc.dart';
import 'package:customer_app/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:customer_app/router/app_router.dart';

final getIt = GetIt.instance;

/// Hand-wired dependency graph. No build_runner/injectable codegen is used —
/// this file plays the role that a generated `injection.config.dart` would.
Future<void> configureDependencies() async {
  // Core services
  getIt.registerLazySingleton(() => SecureStorageService());
  getIt.registerLazySingleton(() => LocalStorageService());
  getIt.registerLazySingleton(() => WebSocketService());

  // Network
  getIt.registerLazySingleton(() => AuthInterceptor(getIt<SecureStorageService>()));
  getIt.registerLazySingleton(() => LoggingInterceptor());
  getIt.registerLazySingleton(() => RetryInterceptor());
  getIt.registerLazySingleton(() => ErrorInterceptor());
  getIt.registerLazySingleton(() => DioClient(
        authInterceptor: getIt<AuthInterceptor>(),
        loggingInterceptor: getIt<LoggingInterceptor>(),
        retryInterceptor: getIt<RetryInterceptor>(),
        errorInterceptor: getIt<ErrorInterceptor>(),
      ));

  // Auth
  getIt.registerLazySingleton(() => AuthRemoteDatasource(getIt<DioClient>()));
  getIt.registerLazySingleton(() => AuthLocalDatasource(getIt<SecureStorageService>(), getIt<LocalStorageService>()));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<AuthRemoteDatasource>(), getIt<AuthLocalDatasource>()));
  getIt.registerFactory(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => GetCurrentUserUseCase(getIt<AuthRepository>()));

  // Restaurants / Orders
  getIt.registerLazySingleton(() => RestaurantRemoteDatasource(getIt<DioClient>()));
  getIt.registerLazySingleton(() => RestaurantRepository(getIt<RestaurantRemoteDatasource>()));
  getIt.registerLazySingleton(() => OrderRemoteDatasource(getIt<DioClient>()));
  getIt.registerLazySingleton(() => OrderRepository(getIt<OrderRemoteDatasource>()));
  getIt.registerLazySingleton(() => AddressRepository(getIt<LocalStorageService>()));
  getIt.registerLazySingleton(() => NotificationRemoteDatasource(getIt<DioClient>()));
  getIt.registerLazySingleton(() => NotificationRepository(getIt<NotificationRemoteDatasource>()));
  getIt.registerLazySingleton(() => ReviewRemoteDatasource(getIt<DioClient>()));
  getIt.registerLazySingleton(() => ReviewRepository(getIt<ReviewRemoteDatasource>()));
  getIt.registerLazySingleton(() => EtaRepository(getIt<DioClient>()));
  getIt.registerLazySingleton(() => CouponRemoteDatasource(getIt<DioClient>()));
  getIt.registerLazySingleton(() => CouponRepository(getIt<CouponRemoteDatasource>()));

  // BLoCs
  // AuthBloc is a singleton: GoRouter's redirect logic and every page need to
  // observe the *same* auth session, not independent copies.
  getIt.registerLazySingleton(() => AuthBloc(getIt<GetCurrentUserUseCase>(), getIt<LogoutUseCase>()));
  getIt.registerFactory(() => LoginBloc(getIt<LoginUseCase>()));
  getIt.registerFactory(() => RegisterBloc(getIt<RegisterUseCase>()));
  getIt.registerFactory(() => HomeBloc(getIt<RestaurantRepository>()));
  getIt.registerFactory(() => RestaurantBloc(getIt<RestaurantRepository>()));
  getIt.registerLazySingleton(() => CartBloc());
  getIt.registerFactory(() => OrderTrackingBloc(getIt<OrderRepository>(), getIt<EtaRepository>(), getIt<WebSocketService>(), getIt<SecureStorageService>()));
  getIt.registerFactory(() => ThemeBloc(getIt<LocalStorageService>()));

  // Router
  getIt.registerLazySingleton(() => AppRouter(getIt<AuthBloc>()));
}
