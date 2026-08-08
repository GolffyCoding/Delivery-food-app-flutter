import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/data/notifications/notification_repository.dart';
import 'package:customer_app/di/injection.dart';
import 'package:customer_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:customer_app/features/order/presentation/pages/order_tracking_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  static const String route = '/notifications';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsBloc(getIt<NotificationRepository>())..add(const NotificationsLoad()),
      child: Scaffold(
        appBar: const AppAppBar(title: 'Notifications', showBackButton: true),
        body: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            return switch (state) {
              NotificationsLoading() => const AppLoadingIndicator(),
              NotificationsError(:final message) => ErrorView(
                  failure: UnknownFailure(message: message),
                  onRetry: () => context.read<NotificationsBloc>().add(const NotificationsLoad()),
                ),
              NotificationsLoaded(:final notifications) => notifications.isEmpty
                  ? const EmptyStateView(icon: Icons.notifications_none_rounded, title: 'No notifications yet')
                  : ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        return ListTile(
                          leading: Icon(
                            n.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                            color: n.isRead ? context.colorScheme.outline : AppColors.brandPrimary,
                          ),
                          title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                          subtitle: Text(n.body),
                          onTap: () {
                            context.read<NotificationsBloc>().add(NotificationTapped(n));
                            if (n.type == 'order' && n.referenceId != null) {
                              context.push('${OrderTrackingPage.route}/${n.referenceId}');
                            }
                          },
                        );
                      },
                    ),
            };
          },
        ),
      ),
    );
  }
}
