import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:opendelivery_notifications/opendelivery_notifications.dart';
import 'package:customer_app/data/notifications/notification_remote_datasource.dart';

NotificationEntity _fromJson(Map<String, dynamic> json) => NotificationEntity(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      isRead: json['is_read'] as bool? ?? json['read'] as bool? ?? false,
      type: json['type'] as String? ?? 'general',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now() : DateTime.now(),
      referenceId: json['reference_id'] as String? ?? json['order_id']?.toString(),
    );

class NotificationRepository {
  final NotificationRemoteDatasource _datasource;
  NotificationRepository(this._datasource);

  Future<Result<List<NotificationEntity>, Failure>> list() async {
    try {
      final json = await _datasource.list();
      return Result.success(json.map((e) => _fromJson(e as Map<String, dynamic>)).toList());
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<int, Failure>> unreadCount() async {
    try {
      return Result.success(await _datasource.unreadCount());
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<void, Failure>> markRead(String id) async {
    try {
      await _datasource.markRead(id);
      return const Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
