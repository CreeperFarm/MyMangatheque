import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/notifications/notification_service.dart';

class NotificationInboxPage extends StatefulWidget {
  NotificationInboxPage({super.key, NotificationService? notificationService})
    : notifications = notificationService ?? NotificationService();

  final NotificationService notifications;

  @override
  State<NotificationInboxPage> createState() => _NotificationInboxPageState();
}

class _NotificationInboxPageState extends State<NotificationInboxPage> {
  StreamSubscription<List<InAppNotification>>? _refreshSubscription;

  NotificationService get _notifications => widget.notifications;

  @override
  void initState() {
    super.initState();
    _refreshSubscription = _notifications.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    unawaited(_refreshSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.localized(en: 'Notifications', fr: 'Notifications'),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: context.localized(
              en: 'Mark all as read',
              fr: 'Tout marquer comme lu',
            ),
            onPressed: _notifications.unreadCount == 0
                ? null
                : _notifications.markAllOpened,
            icon: const Icon(Icons.done_all_rounded),
          ),
          IconButton(
            tooltip: context.localized(
              en: 'Clear notifications',
              fr: 'Effacer les notifications',
            ),
            onPressed: _notifications.notifications.isEmpty
                ? null
                : () => _confirmClear(context),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: StreamBuilder<List<InAppNotification>>(
        stream: _notifications.stream,
        initialData: _notifications.notifications,
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? const <InAppNotification>[];
          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 54,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.localized(
                        en: 'No notifications yet',
                        fr: 'Aucune notification pour le moment',
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.localized(
                        en: 'Release alerts and important account updates will appear here.',
                        fr: 'Les alertes de sortie et les informations importantes du compte apparaîtront ici.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final unread = notification.openedAt == null;
              final hasDestination =
                  PushNotificationRouteResolver.resolve(
                    notification.payload ?? const <String, dynamic>{},
                  ) !=
                  null;
              return Semantics(
                button: hasDestination,
                label: unread
                    ? context.localized(
                        en: 'Unread notification',
                        fr: 'Notification non lue',
                      )
                    : null,
                child: ListTile(
                  tileColor: unread
                      ? Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withAlpha(70)
                      : null,
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      const Icon(Icons.notifications_outlined),
                      if (unread)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    notification.title,
                    style: unread
                        ? const TextStyle(fontWeight: FontWeight.w700)
                        : null,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (notification.body.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(notification.body),
                      ],
                      const SizedBox(height: 5),
                      Text(
                        _formatDate(context, notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: hasDestination
                      ? const Icon(Icons.chevron_right_rounded)
                      : null,
                  onTap: hasDestination
                      ? () => _notifications.openNotification(notification.id)
                      : unread
                      ? () => _notifications.markOpened(notification.id)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime value) {
    final local = value.toLocal();
    final date = MaterialLocalizations.of(context).formatMediumDate(local);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(local));
    return '$date · $time';
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          context.localized(
            en: 'Clear notifications?',
            fr: 'Effacer les notifications ?',
          ),
        ),
        content: Text(
          context.localized(
            en: 'This removes the notification history stored on this device.',
            fr: 'Cette action supprime l’historique des notifications conservé sur cet appareil.',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.localized(en: 'Cancel', fr: 'Annuler')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.localized(en: 'Clear', fr: 'Effacer')),
          ),
        ],
      ),
    );
    if (confirmed == true) _notifications.clearInApp();
  }
}
