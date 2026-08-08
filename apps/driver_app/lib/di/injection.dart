import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:opendelivery_sync/opendelivery_sync.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/core/app_messenger.dart';
import 'package:driver_app/data/driver_remote_datasource.dart';
import 'package:driver_app/data/driver_repository.dart';
import 'package:driver_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:driver_app/features/auth/presentation/bloc/auth_form_bloc.dart';
import 'package:driver_app/features/home/bloc/driver_online_bloc.dart';
import 'package:driver_app/features/incoming_order/bloc/incoming_order_bloc.dart';
import 'package:driver_app/features/active_delivery/bloc/active_delivery_bloc.dart';
import 'package:driver_app/router/app_router.dart';

final getIt = GetIt.instance;

/// Hand-wired dependency graph (no build_runner/injectable codegen).
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

  // Driver domain
  getIt.registerLazySingleton(() => DriverRemoteDatasource(getIt<DioClient>()));
  getIt.registerLazySingleton(() => DriverRepository(getIt<DriverRemoteDatasource>()));

  // Offline sync (order-accept idempotency)
  getIt.registerLazySingleton(() => SyncQueue(getIt<LocalStorageService>()));
  getIt.registerLazySingleton(() => SyncManager(getIt<SyncQueue>(), getIt<DioClient>(), Connectivity()));

  // BLoCs
  getIt.registerLazySingleton(() => AuthBloc(getIt<GetCurrentUserUseCase>(), getIt<LogoutUseCase>()));
  getIt.registerFactory(() => AuthFormBloc(getIt<LoginUseCase>(), getIt<RegisterUseCase>(), getIt<DriverRepository>()));
  getIt.registerFactory(() => DriverOnlineBloc(getIt<WebSocketService>(), getIt<DriverRepository>(), getIt<SecureStorageService>()));
  getIt.registerFactory(() => IncomingOrderBloc(getIt<SyncQueue>()));
  getIt.registerFactory(() => ActiveDeliveryBloc(getIt<DriverRepository>()));

  // Router
  getIt.registerLazySingleton(() => AppRouter(getIt<AuthBloc>()));

  getIt<SyncManager>().start();

  // A request that exhausted its retries used to just vanish into a log
  // line — the driver would have no idea an "accept order" or status update
  // never actually reached the backend. Surface it instead.
  getIt<SyncManager>().permanentFailures.listen((request) {
    appMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Action could not be sent to the server (${request.path}). Please check this order manually.'),
        duration: const Duration(seconds: 6),
      ),
    );
  });
}
