import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

/// Talks to `/drivers` and `/driver/orders`.
class DriverRemoteDatasource {
  final DioClient _dioClient;
  DriverRemoteDatasource(this._dioClient);

  Future<void> register({required String vehicleType, String? licensePlate, String? vehicleColor}) {
    return _dioClient.post(ApiConstants.driverRegister, data: {
      'vehicle_type': vehicleType,
      if (licensePlate != null) 'license_plate': licensePlate,
      if (vehicleColor != null) 'vehicle_color': vehicleColor,
    });
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _dioClient.get<Map<String, dynamic>>(ApiConstants.driverMe, decoder: (json) => json as Map<String, dynamic>);
    return response.data ?? const {};
  }

  Future<void> goOnline() => _dioClient.post(ApiConstants.driverOnline);

  Future<void> goOffline() => _dioClient.post(ApiConstants.driverOffline);

  Future<void> sendLocation({required double latitude, required double longitude}) {
    return _dioClient.post(ApiConstants.driverLocation, data: {'latitude': latitude, 'longitude': longitude});
  }

  Future<Map<String, dynamic>> earnings() async {
    final response = await _dioClient.get<Map<String, dynamic>>(ApiConstants.driverEarnings, decoder: (json) => json as Map<String, dynamic>);
    return response.data ?? const {};
  }

  Future<List<dynamic>> listOrders() async {
    final response = await _dioClient.get<List<dynamic>>(ApiConstants.driverOrders, decoder: (json) => json as List<dynamic>);
    return response.data ?? const [];
  }

  Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.driverOrderAccept(orderId),
      decoder: (json) => json as Map<String, dynamic>,
    );
    return response.data ?? const {};
  }

  Future<void> updateOrderStatus(String orderId, String status) {
    return _dioClient.put(ApiConstants.driverOrderStatus(orderId), data: {'status': status});
  }
}
