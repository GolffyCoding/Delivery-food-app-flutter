import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

/// Talks to the `/restaurants/:restaurant_id/menu` endpoints.
class MenuDatasource {
  final DioClient _dioClient;
  MenuDatasource(this._dioClient);

  Future<List<dynamic>> getItems(String restaurantId) async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiConstants.menuItems(restaurantId),
      decoder: (json) => json as List<dynamic>,
    );
    return response.data ?? const [];
  }

  Future<Map<String, dynamic>> createItem(String restaurantId, Map<String, dynamic> body) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.menuItems(restaurantId),
      data: body,
      decoder: (json) => json as Map<String, dynamic>,
    );
    return response.data ?? const {};
  }

  Future<void> updateItem(String itemId, Map<String, dynamic> body) {
    return _dioClient.put(ApiConstants.menuItemById(itemId), data: body);
  }

  Future<void> deleteItem(String itemId) {
    return _dioClient.delete(ApiConstants.menuItemById(itemId));
  }
}
