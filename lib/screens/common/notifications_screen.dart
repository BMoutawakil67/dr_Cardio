import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _todayNotifications = [
    NotificationItem(
      icon: '🔔',
      title: 'Rappel',
      message: 'Il est temps de prendre votre tension',
      time: '18:00',
      type: NotificationType.reminder,
      isRead: false,
    ),
    NotificationItem(
      icon: '💬',
      title: 'Nouveau message',
      message: 'Dr. Kouassi vous a répondu',
      time: '15:30',
      type: NotificationType.message,
      isRead: false,
    ),
    NotificationItem(
      icon: '💊',
      title: 'Rappel médicament',
      message: 'Losartan 50mg',
      time: '08:00',
      type: NotificationType.medication,
      isRead: true,
    ),
  ];

  final List<NotificationItem> _yesterdayNotifications = [
    NotificationItem(
      icon: '⚠️',
      title: 'Alerte tension',
      message: 'Votre tension est légèrement élevée',
      time: '19:15',
      type: NotificationType.alert,
      isRead: true,
    ),
    NotificationItem(
      icon: '🎉',
      title: 'Objectif atteint',
      message: '10 000 pas aujourd\'hui!',
      time: '22:00',
      type: NotificationType.achievement,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hasUnread = _todayNotifications.any((n) => !n.isRead) ||
        _yesterdayNotifications.any((n) => !n.isRead);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Aujourd'hui
                const Text(
                  'Aujourd\'hui',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                ..._todayNotifications.map((notification) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NotificationCard(
                      notification: notification,
                      onTap: () => _handleNotificationTap(notification),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Hier
                const Text(
                  'Hier',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                ..._yesterdayNotifications.map((notification) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NotificationCard(
                      notification: notification,
                      onTap: () => _handleNotificationTap(notification),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bouton "Tout marquer comme lu"
          if (hasUnread)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _markAllAsRead,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.primaryBlue),
                  ),
                  child: const Text(
                    'Tout marquer comme lu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });

    // Navigation en fonction du type de notification
    switch (notification.type) {
      case NotificationType.message:
        // TODO: Naviguer vers les messages
        break;
      case NotificationType.alert:
        // TODO: Naviguer vers l'historique
        break;
      case NotificationType.reminder:
        // TODO: Naviguer vers l'enregistrement
        break;
      case NotificationType.medication:
        // TODO: Afficher les détails du médicament
        break;
      case NotificationType.achievement:
        // Afficher un message de félicitations
        _showAchievementDialog();
        break;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _todayNotifications) {
        notification.isRead = true;
      }
      for (var notification in _yesterdayNotifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Toutes les notifications ont été marquées comme lues'),
        backgroundColor: AppTheme.successGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAchievementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('🎉', style: TextStyle(fontSize: 32)),
            SizedBox(width: 12),
            Text('Félicitations!'),
          ],
        ),
        content: const Text(
          'Vous avez atteint votre objectif de 10 000 pas! Continuez comme ça!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Merci!'),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? AppTheme.greyLight : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(
                color: _getTypeColor().withValues(alpha: 0.3),
                width: 1,
              ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTypeColor().withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    notification.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                notification.isRead ? FontWeight.w500 : FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.greyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.alert:
        return AppTheme.secondaryRed;
      case NotificationType.message:
        return AppTheme.primaryBlue;
      case NotificationType.reminder:
        return AppTheme.warningOrange;
      case NotificationType.medication:
        return AppTheme.successGreen;
      case NotificationType.achievement:
        return AppTheme.successGreen;
    }
  }
}

enum NotificationType {
  reminder,
  message,
  medication,
  alert,
  achievement,
}

class NotificationItem {
  final String icon;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}
