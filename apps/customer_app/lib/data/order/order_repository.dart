import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:customer_app/data/order/order_remote_datasource.dart';
import 'package:customer_app/domain/models/cart_item_model.dart';
import 'package:customer_app/domain/models/order_model.dart';

class OrderRepository {
  final OrderRemoteDatasource _datasource;
  OrderRepository(this._datasource);

  Future<Result<OrderModel, Failure>> createOrder({
    required String restaurantId,
    required List<CartItemModel> items,
    required String paymentMethod,
    required String deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    String? couponCode,
    required String idempotencyKey,
  }) async {
    try {
      final json = await _datasource.createOrder(
        restaurantId: restaurantId,
        items: items
            .map((item) => {
                  'menu_item_id': item.food.id,
                  'name': item.food.name,
                  'quantity': item.quantity,
                  'unit_price': item.food.currentPrice,
                })
            .toList(),
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        deliveryLat: deliveryLat,
        deliveryLng: deliveryLng,
        couponCode: couponCode,
        idempotencyKey: idempotencyKey,
      );
      return Result.success(OrderModel.fromJson(json));
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<List<OrderModel>, Failure>> listMyOrders() async {
    try {
      final json = await _datasource.listMyOrders();
      return Result.success(json.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList());
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<OrderModel, Failure>> getById(String id) async {
    try {
      final json = await _datasource.getById(id);
      return Result.success(OrderModel.fromJson(json));
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<void, Failure>> cancel(String id, {String? reason}) async {
    try {
      await _datasource.cancel(id, reason: reason);
      return const Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
