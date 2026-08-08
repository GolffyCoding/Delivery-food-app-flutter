import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

class ReviewRemoteDatasource {
  final DioClient _dioClient;
  ReviewRemoteDatasource(this._dioClient);

  Future<Map<String, dynamic>> create({
    required String orderId,
    required String restaurantId,
    String? driverId,
    required int rating,
    String comment = '',
    List<String> photoUrls = const [],
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.reviews,
      data: {
        'order_id': orderId,
        'restaurant_id': restaurantId,
        if (driverId != null) 'driver_id': driverId,
        'rating': rating,
        'comment': comment,
        'photo_urls': photoUrls,
      },
      decoder: (json) => json as Map<String, dynamic>,
    );
    return response.data ?? const {};
  }

  Future<List<dynamic>> listByRestaurant(String restaurantId, {int page = 1, int perPage = 20}) async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiConstants.restaurantReviews(restaurantId),
      queryParameters: {'page': page, 'per_page': perPage},
      decoder: (json) => json as List<dynamic>,
    );
    return response.data ?? const [];
  }

  Future<Map<String, dynamic>> summary(String restaurantId) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.restaurantReviewSummary(restaurantId),
      decoder: (json) => json as Map<String, dynamic>,
    );
    return response.data ?? const {};
  }
}
