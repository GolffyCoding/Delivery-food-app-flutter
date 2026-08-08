import 'package:opendelivery_notifications/opendelivery_notifications.dart';

/// Parses raw push-notification payloads into [NotificationEntity].
/// NOTE: this package intentionally has no Firebase dependency here since
/// that requires a real Firebase project (google-services.json / GoogleService-Info.plist).
/// Wire up `firebase_messaging` in the consuming app once that config exists.
class NotificationService {
  const NotificationService();

  NotificationEntity parseNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return NotificationEntity(
      id: data?['notificationId'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      imageUrl: data?['imageUrl'] as String?,
      type: data?['type'] as String? ?? 'general',
      createdAt: DateTime.now(),
      referenceId: data?['referenceId'] as String?,
    );
  }
}
