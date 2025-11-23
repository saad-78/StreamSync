import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notification = _DemoNotification.demo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.space4),
            child: Dismissible(
              key: Key(notification.id),
              direction: DismissDirection.none, // Prevent delete for demo
              background: Container(),
              child: InkWell(
                onTap: () {}, // No action on tap
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.space4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppTheme.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: AppTheme.space1),
                            Text(
                              notification.body,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppTheme.space1),
                            Text(
                              timeago.format(notification.receivedAt),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _DemoNotification {
  static final NotificationModel demo = NotificationModel(
    id: "demo",
    title: "Test Notification",
    body: "This is a test push notification",
    receivedAt: DateTime.now().subtract(const Duration(minutes: 1)),
  );
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
  });
}
