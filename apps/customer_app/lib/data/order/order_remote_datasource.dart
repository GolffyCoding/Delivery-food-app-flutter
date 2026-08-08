import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

/// Talks to the customer-facing `/orders` endpoints.
class OrderRemoteDatasource {
  final DioClient _dioClient;
  OrderRemoteDatasource(this._dioClient);

  Future<Map<String, dynamic>> createOrder({
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    required String deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    String? couponCode,
    required String idempotencyKey,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.orders,
      idempotencyKey: idempotencyKey,
      data: {
        'restaurant_id': restaurantId,
        'items': items,
        'payment_method': paymentMethod,
        'delivery_address': deliveryAddress,
        if (deliveryLat != null) 'delivery_lat': deliveryLat,
        if (deliveryLng != null) 'delivery_lng': deliveryLng,
        if (couponCode != null) 'coupon_code': couponCode,
      },
      decoder: (json) => json as Map<String, dynamic>,
    );
    return response.data ?? const {};
  }

  Future<List<dynamic>> listMyOrders({int page = 1, int perPage = 20}) async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiConstants.orders,
      queryParameters: {'page': page, 'per_page': perPage},
      decoder: (json) => json as List<dynamic>,
    );
    return response.data ?? const [];
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.orderById(id),
      decoder: (json) => json as Map<String, dynamic>,
    );
    return response.data ?? const {};
  }

  Future<void> cancel(String id, {String? reason}) async {
    await _dioClient.post(ApiConstants.orderCancel(id), data: {if (reason != null) 'reason': reason});
  }
}
