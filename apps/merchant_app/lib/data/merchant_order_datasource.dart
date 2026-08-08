import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

/// Talks to the merchant-facing order endpoints.
class MerchantOrderDatasource {
  final DioClient _dioClient;
  MerchantOrderDatasource(this._dioClient);

  Future<List<dynamic>> listOrders(String restaurantId) async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiConstants.restaurantOrders(restaurantId),
      decoder: (json) => json as List<dynamic>,
    );
    return response.data ?? const [];
  }

  Future<List<dynamic>> listPendingOrders(String restaurantId) async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiConstants.restaurantOrdersPending(restaurantId),
      decoder: (json) => json as List<dynamic>,
    );
    return response.data ?? const [];
  }

  /// [status] must be one of: accepted | preparing | ready | cancelled.
  Future<void> updateStatus(String orderId, String status) {
    return _dioClient.put(ApiConstants.orderStatus(orderId), data: {'status': status});
  }
}
