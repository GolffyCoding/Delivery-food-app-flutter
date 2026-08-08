import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:customer_app/data/review/review_remote_datasource.dart';
import 'package:customer_app/domain/models/review_model.dart';

class ReviewRepository {
  final ReviewRemoteDatasource _datasource;
  ReviewRepository(this._datasource);

  Future<Result<ReviewModel, Failure>> create({
    required String orderId,
    required String restaurantId,
    String? driverId,
    required int rating,
    String comment = '',
  }) async {
    try {
      final json = await _datasource.create(
        orderId: orderId,
        restaurantId: restaurantId,
        driverId: driverId,
        rating: rating,
        comment: comment,
      );
      return Result.success(ReviewModel.fromJson(json));
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<List<ReviewModel>, Failure>> listByRestaurant(String restaurantId) async {
    try {
      final json = await _datasource.listByRestaurant(restaurantId);
      return Result.success(json.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList());
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<RatingSummaryModel, Failure>> summary(String restaurantId) async {
    try {
      final json = await _datasource.summary(restaurantId);
      return Result.success(RatingSummaryModel.fromJson(json));
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
