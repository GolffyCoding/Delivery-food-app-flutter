import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

/// Talks to the `/restaurants` and menu endpoints.
class RestaurantRemoteDatasource {
  final DioClient _dioClient;
  RestaurantRemoteDatasource(this._dioClient);

  Future<List<dynamic>> getRestaurants({int page = 1, int perPage = 20, String? cuisine, double? minRating}) async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiConstants.restaurants,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (cuisine != null) 'cuisine': cuisine,
        if (minRating != null) 'min_rating': minRating,
      },
      decoder: (json) => json as List<dynamic>,
    );
    return response.data ?? const [];
  }

  Future<List<dynamic>> getFeatured() async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiConstants.restaurantsFeatured,
      decoder: (json) => json as List<dynamic>,
    );
    return response.data ?? const [];
  }

  Future<List<dynamic>> getNearby({required double latitude, required double longitude, double radiusKm = 10, int? limit}) async {
    final response = await _dioClient.post<List<dynamic>>(
      ApiConstants.restaurantsNearby,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'radius_km': radiusKm,
        if (limit != null) 'limit': limit,
      },
      decoder: (json) => json as List<dynamic>,
    );
    return response.data ?? const [];
  }

  Future<List<dynamic>> search(String query) async {
    final response = await _dioClient.post<List<dynamic>>(
      ApiConstants.restaurantsSearch,
      data: {'query': query},
      decoder: (json) => json as List<dynamic>,
    );
    return response.data ?? const [];
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.restaurantById(id),
      decoder: (json) => json as Map<String, dynamic>,
    );
    return response.data ?? const {};
  }

  Future<List<dynamic>> getMenuItems(String restaurantId) async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiConstants.menuItems(restaurantId),
      decoder: (json) => json as List<dynamic>,
    );
    return response.data ?? const [];
  }
}
