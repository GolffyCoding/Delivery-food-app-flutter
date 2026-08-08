import 'package:get_it/get_it.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';
import 'package:merchant_app/data/merchant_restaurant_datasource.dart';
import 'package:merchant_app/data/merchant_order_datasource.dart';
import 'package:merchant_app/data/menu_datasource.dart';
import 'package:merchant_app/data/review/review_remote_datasource.dart';
import 'package:merchant_app/data/review/review_repository.dart';
import 'package:merchant_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:merchant_app/features/auth/presentation/bloc/auth_form_bloc.dart';
import 'package:merchant_app/features/restaurant_setup/bloc/restaurant_session_bloc.dart';
import 'package:merchant_app/features/dashboard/bloc/merchant_order_bloc.dart';
import 'package:merchant_app/features/menu/bloc/menu_bloc.dart';
import 'package:merchant_app/features/sales/bloc/sales_bloc.dart';
import 'package:merchant_app/router/app_router.dart';

final getIt = GetIt.instance;

/// Hand-wired dependency graph (no build_runner/injectable codegen).
Future<void> configureDependencies() async {
  getIt.registerLazySingleton(() => SecureStorageService());
  getIt.registerLazySingleton(() => LocalStorageService());
  getIt.registerLazySingleton(() => WebSocketService());

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

  // Merchant domain
  getIt.registerLazySingleton(() => MerchantRestaurantDatasource(getIt<DioClient>()));
  getIt.registerLazySingleton(() => MerchantOrderDatasource(getIt<DioClient>()));
  getIt.registerLazySingleton(() => MenuDatasource(getIt<DioClient>()));
  getIt.registerLazySingleton(() => ReviewRemoteDatasource(getIt<DioClient>()));
  getIt.registerLazySingleton(() => ReviewRepository(getIt<ReviewRemoteDatasource>()));

  // BLoCs
  getIt.registerLazySingleton(() => AuthBloc(getIt<GetCurrentUserUseCase>(), getIt<LogoutUseCase>()));
  getIt.registerFactory(() => AuthFormBloc(getIt<LoginUseCase>(), getIt<RegisterUseCase>()));
  // Shared across the whole app once created: every screen needs to know
  // which restaurant we're managing.
  getIt.registerLazySingleton(() => RestaurantSessionBloc(getIt<MerchantRestaurantDatasource>()));
  getIt.registerFactory(() => MerchantOrderBloc(getIt<MerchantOrderDatasource>()));
  getIt.registerFactory(() => MenuBloc(getIt<MenuDatasource>()));
  getIt.registerFactory(() => SalesBloc());

  // Router
  getIt.registerLazySingleton(() => AppRouter(getIt<AuthBloc>()));
}
