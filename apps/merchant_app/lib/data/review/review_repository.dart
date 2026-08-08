import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:merchant_app/data/review/review_remote_datasource.dart';
import 'package:merchant_app/domain/models/review_model.dart';

class ReviewRepository {
  final ReviewRemoteDatasource _datasource;
  ReviewRepository(this._datasource);

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

  Future<Result<void, Failure>> reply(String restaurantId, String reviewId, String reply) async {
    try {
      await _datasource.reply(restaurantId, reviewId, reply);
      return const Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
