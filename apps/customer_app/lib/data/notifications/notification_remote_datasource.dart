import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

class NotificationRemoteDatasource {
  final DioClient _dioClient;
  NotificationRemoteDatasource(this._dioClient);

  Future<List<dynamic>> list() async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiConstants.notifications,
      decoder: (json) => json as List<dynamic>,
    );
    return response.data ?? const [];
  }

  Future<int> unreadCount() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.notificationsUnreadCount,
      decoder: (json) => json as Map<String, dynamic>,
    );
    return (response.data?['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(String id) {
    return _dioClient.put(ApiConstants.notificationRead(id));
  }
}
