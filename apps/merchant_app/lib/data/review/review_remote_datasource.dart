import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

class ReviewRemoteDatasource {
  final DioClient _dioClient;
  ReviewRemoteDatasource(this._dioClient);

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

  Future<void> reply(String restaurantId, String reviewId, String reply) {
    return _dioClient.post(ApiConstants.restaurantReviewReply(restaurantId, reviewId), data: {'reply': reply});
  }
}
