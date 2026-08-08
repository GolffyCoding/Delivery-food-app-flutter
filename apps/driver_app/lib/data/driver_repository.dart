import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:driver_app/data/driver_remote_datasource.dart';

class DriverRepository {
  final DriverRemoteDatasource _datasource;
  DriverRepository(this._datasource);

  Future<Result<void, Failure>> register({required String vehicleType, String? licensePlate, String? vehicleColor}) => _guard(
        () => _datasource.register(vehicleType: vehicleType, licensePlate: licensePlate, vehicleColor: vehicleColor),
      );

  Future<Result<void, Failure>> goOnline() => _guard(() => _datasource.goOnline());

  Future<Result<void, Failure>> goOffline() => _guard(() => _datasource.goOffline());

  Future<Result<void, Failure>> sendLocation({required double latitude, required double longitude}) =>
      _guard(() => _datasource.sendLocation(latitude: latitude, longitude: longitude));

  Future<Result<Map<String, dynamic>, Failure>> earnings() async {
    try {
      return Result.success(await _datasource.earnings());
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<List<dynamic>, Failure>> listOrders() async {
    try {
      return Result.success(await _datasource.listOrders());
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<void, Failure>> updateOrderStatus(String orderId, String status) =>
      _guard(() => _datasource.updateOrderStatus(orderId, status));

  Future<Result<void, Failure>> _guard(Future<void> Function() call) async {
    try {
      await call();
      return const Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
