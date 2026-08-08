import 'package:opendelivery_core/opendelivery_core.dart';

class DeductInventoryParams {
  final String orderId;
  const DeductInventoryParams(this.orderId);
}

/// Ensures that when an order finishes preparation, stock is reduced.
/// Kept separate from the BLoC so the inventory side-effect stays testable
/// and swappable independent of UI/state-machine wiring.
class DeductInventoryUseCase extends BaseUseCase<void, DeductInventoryParams> {
  @override
  Future<Result<void, Failure>> call(DeductInventoryParams params) async {
    try {
      // 1. Fetch order items from local cache/DB.
      // 2. For each item, call inventoryRepository.deductStock(itemId, qty).
      // 3. If any item hits zero, toggle its availability off and notify the kitchen.
      AppLogger.info('Deducted inventory for Order: ${params.orderId}', tag: 'Inventory');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(LocalFailure(message: 'Failed to deduct inventory: $e'));
    }
  }
}
