import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_notifications/opendelivery_notifications.dart';
import 'package:customer_app/data/notifications/notification_repository.dart';

sealed class NotificationsEvent {
  const NotificationsEvent();
}

class NotificationsLoad extends NotificationsEvent {
  const NotificationsLoad();
}

class NotificationTapped extends NotificationsEvent {
  final NotificationEntity notification;
  const NotificationTapped(this.notification);
}

sealed class NotificationsState {
  const NotificationsState();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  const NotificationsLoaded(this.notifications);
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository _repository;

  NotificationsBloc(this._repository) : super(const NotificationsLoading()) {
    on<NotificationsLoad>(_onLoad);
    on<NotificationTapped>(_onTapped);
  }

  Future<void> _onLoad(NotificationsLoad event, Emitter<NotificationsState> emit) async {
    emit(const NotificationsLoading());
    final result = await _repository.list();
    result.when(
      success: (notifications) => emit(NotificationsLoaded(notifications)),
      failure: (failure) => emit(NotificationsError(failure.message)),
    );
  }

  Future<void> _onTapped(NotificationTapped event, Emitter<NotificationsState> emit) async {
    if (event.notification.isRead) return;
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Mark read locally first for a snappy UI, but this list is reloaded
    // from `NotificationsLoad` on next visit, so a failed backend call just
    // means the badge count is briefly stale rather than silently wrong.
    emit(NotificationsLoaded([
      for (final n in current.notifications)
        if (n.id == event.notification.id)
          NotificationEntity(
            id: n.id,
            title: n.title,
            body: n.body,
            imageUrl: n.imageUrl,
            isRead: true,
            type: n.type,
            createdAt: n.createdAt,
            referenceId: n.referenceId,
          )
        else
          n,
    ]));
    await _repository.markRead(event.notification.id);
  }
}
