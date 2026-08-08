import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:customer_app/data/restaurant/restaurant_remote_datasource.dart';
import 'package:customer_app/domain/models/restaurant_model.dart';
import 'package:customer_app/domain/models/food_item_model.dart';

class RestaurantRepository {
  final RestaurantRemoteDatasource _datasource;
  RestaurantRepository(this._datasource);

  Future<Result<List<RestaurantModel>, Failure>> getRestaurants() async {
    try {
      final json = await _datasource.getRestaurants();
      return Result.success(json.map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>)).toList());
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<List<RestaurantModel>, Failure>> getFeatured() async {
    try {
      final json = await _datasource.getFeatured();
      return Result.success(json.map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>)).toList());
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<List<RestaurantModel>, Failure>> search(String query) async {
    try {
      final json = await _datasource.search(query);
      return Result.success(json.map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>)).toList());
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<RestaurantModel, Failure>> getById(String id) async {
    try {
      final json = await _datasource.getById(id);
      return Result.success(RestaurantModel.fromJson(json));
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<List<FoodItemModel>, Failure>> getMenu(String restaurantId) async {
    try {
      final json = await _datasource.getMenuItems(restaurantId);
      return Result.success(json.map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>, restaurantId: restaurantId)).toList());
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
