import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

/// Talks to the merchant-facing `/restaurants` endpoints.
class MerchantRestaurantDatasource {
  final DioClient _dioClient;
  MerchantRestaurantDatasource(this._dioClient);

  /// Returns the merchant's restaurant, or `null` if none has been created
  /// yet. NOTE: `GET /restaurants/my` returns a *list* — a merchant account
  /// can technically own more than one, but this app manages just the first.
  Future<Map<String, dynamic>?> getMyRestaurant() async {
    final response = await _dioClient.get<List<dynamic>>(ApiConstants.restaurantsMy);
    final list = response.data;
    if (list == null || list.isEmpty) return null;
    return list.first as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> create({
    required String name,
    required List<String> cuisineTypes,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required double deliveryRadiusKm,
    required List<Map<String, dynamic>> openingHours,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.restaurants,
      data: {
        'name': name,
        'cuisine_types': cuisineTypes,
        'phone': phone,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'delivery_radius_km': deliveryRadiusKm,
        'opening_hours': openingHours,
      },
      decoder: (json) => json as Map<String, dynamic>,
    );
    return response.data ?? const {};
  }

  Future<void> update(String id, Map<String, dynamic> body) {
    return _dioClient.put(ApiConstants.restaurantById(id), data: body);
  }
}
