import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/notification.dart' as models;
import '../../models/user.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../core/utils/responsive.dart';

/// Notifications menu widget that appears when clicking the notification button
class NotificationsMenu extends StatelessWidget {
  const NotificationsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotificationProvider, AuthProvider>(
      builder: (context, notificationProvider, authProvider, _) {
        final user = authProvider.currentUser;
        if (user == null) {
          return const SizedBox.shrink();
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: Responsive.isMobile(context) ? double.infinity : 400,
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Notifications',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (notificationProvider.unreadCount > 0)
                        TextButton.icon(
                          onPressed: () async {
                            await notificationProvider.markAllAsRead(user.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('All notifications marked as read'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.done_all, size: 18),
                          label: const Text('Mark all read'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Notifications list
                Flexible(
                  child: notificationProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : notificationProvider.notifications.isEmpty
                          ? _buildEmptyState(context)
                          : RefreshIndicator(
                              onRefresh: () async {
                                await notificationProvider.loadNotifications(user.id);
                                await notificationProvider.loadUnreadCount(user.id);
                              },
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: notificationProvider.notifications.length,
                                padding: const EdgeInsets.all(8),
                                itemBuilder: (context, index) {
                                  final notification =
                                      notificationProvider.notifications[index];
                                  return _NotificationItem(
                                    notification: notification,
                                    onTap: () async {
                                      if (!notification.read) {
                                        await notificationProvider.markAsRead(
                                          notification.id,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                ),
                // Footer with test notification button (admin only)
                if (user.role == Role.admin)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showTestNotificationDialog(
                              context,
                              notificationProvider,
                              user.id,
                            ),
                            icon: const Icon(Icons.add_alert, size: 18),
                            label: const Text('Test Notification'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTestNotificationDialog(
    BuildContext context,
    NotificationProvider notificationProvider,
    int userId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Test Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select notification type:'),
            const SizedBox(height: 16),
            ...models.NotificationType.values.map((type) {
              return ListTile(
                dense: true,
                leading: Icon(_getNotificationIcon(type)),
                title: Text(_getNotificationTypeLabel(type)),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _createTestNotification(
                    context,
                    notificationProvider,
                    userId,
                    type,
                  );
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _createTestNotification(
    BuildContext context,
    NotificationProvider notificationProvider,
    int userId,
    models.NotificationType type,
  ) {
    final now = DateTime.now();
    final testNotification = models.Notification(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: userId,
      type: type,
      title: _getTestNotificationTitle(type),
      message: _getTestNotificationMessage(type),
      isRead: false,
      createdAt: now,
    );

    // Add notification to provider
    notificationProvider.addNotification(testNotification);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test ${_getNotificationTypeLabel(type)} notification created!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getNotificationTypeLabel(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.bookingConfirmed:
        return 'Booking Confirmed';
      case models.NotificationType.bookingReminder:
        return 'Booking Reminder';
      case models.NotificationType.bookingCanceled:
        return 'Booking Canceled';
      case models.NotificationType.bookingExpired:
        return 'Booking Expired';
      case models.NotificationType.noShow:
        return 'No Show';
      case models.NotificationType.noShowAlert:
        return 'No Show Alert';
      case models.NotificationType.checkInReminder:
        return 'Check-In Reminder';
      case models.NotificationType.resourceCreated:
        return 'New Resource';
      case models.NotificationType.resourceDeleted:
        return 'Resource Removed';
      case models.NotificationType.policyCreated:
        return 'New Policy';
      case models.NotificationType.policyUpdated:
        return 'Policy Updated';
      case models.NotificationType.policyDeleted:
        return 'Policy Removed';
      case models.NotificationType.system:
        return 'System';
    }
  }

  IconData _getNotificationIcon(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.bookingConfirmed:
        return Icons.check_circle;
      case models.NotificationType.bookingReminder:
        return Icons.alarm;
      case models.NotificationType.bookingCanceled:
        return Icons.cancel;
      case models.NotificationType.bookingExpired:
        return Icons.access_time;
      case models.NotificationType.noShow:
        return Icons.person_off;
      case models.NotificationType.noShowAlert:
        return Icons.person_off;
      case models.NotificationType.checkInReminder:
        return Icons.qr_code_scanner;
      case models.NotificationType.resourceCreated:
        return Icons.add_circle;
      case models.NotificationType.resourceDeleted:
        return Icons.remove_circle;
      case models.NotificationType.policyCreated:
        return Icons.policy;
      case models.NotificationType.policyUpdated:
        return Icons.update;
      case models.NotificationType.policyDeleted:
        return Icons.delete_outline;
      case models.NotificationType.system:
        return Icons.info;
    }
  }

  String _getTestNotificationTitle(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.bookingConfirmed:
        return 'Test: Booking Confirmed';
      case models.NotificationType.bookingReminder:
        return 'Test: Booking Reminder';
      case models.NotificationType.bookingCanceled:
        return 'Test: Booking Canceled';
      case models.NotificationType.bookingExpired:
        return 'Test: Booking Expired';
      case models.NotificationType.noShow:
        return 'Test: No Show';
      case models.NotificationType.noShowAlert:
        return 'Test: No Show Alert';
      case models.NotificationType.checkInReminder:
        return 'Test: Check-In Reminder';
      case models.NotificationType.resourceCreated:
        return 'Test: New Resource';
      case models.NotificationType.resourceDeleted:
        return 'Test: Resource Removed';
      case models.NotificationType.policyCreated:
        return 'Test: New Policy';
      case models.NotificationType.policyUpdated:
        return 'Test: Policy Updated';
      case models.NotificationType.policyDeleted:
        return 'Test: Policy Removed';
      case models.NotificationType.system:
        return 'Test: System Notification';
    }
  }

  String _getTestNotificationMessage(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.bookingConfirmed:
        return 'This is a test booking confirmation notification. Your booking has been successfully created.';
      case models.NotificationType.bookingReminder:
        return 'This is a test reminder. Your booking starts in 30 minutes.';
      case models.NotificationType.bookingCanceled:
        return 'This is a test cancellation notification. Your booking has been canceled.';
      case models.NotificationType.bookingExpired:
        return 'This is a test expiry notification. Your booking has expired.';
      case models.NotificationType.noShow:
        return 'This is a test no-show notification. You did not check in for your booking.';
      case models.NotificationType.noShowAlert:
        return 'This is a test no-show alert notification. You did not check in for your booking.';
      case models.NotificationType.checkInReminder:
        return 'This is a test check-in reminder. Please check in to your booking.';
      case models.NotificationType.resourceCreated:
        return 'This is a test resource creation notification. A new resource has been added.';
      case models.NotificationType.resourceDeleted:
        return 'This is a test resource deletion notification. A resource has been removed.';
      case models.NotificationType.policyCreated:
        return 'This is a test policy creation notification. A new policy has been implemented.';
      case models.NotificationType.policyUpdated:
        return 'This is a test policy update notification. A policy has been updated.';
      case models.NotificationType.policyDeleted:
        return 'This is a test policy deletion notification. A policy has been removed.';
      case models.NotificationType.system:
        return 'This is a test system notification. The system is operating normally.';
    }
  }
}

class _NotificationItem extends StatelessWidget {
  final models.Notification notification;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final icon = _getNotificationIcon(notification.type);
    final color = _getNotificationColor(notification.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnread
              ? color.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isUnread
              ? Border.all(color: color.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date_utils.AppDateUtils.formatRelativeTime(
                      notification.createdAt,
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.bookingConfirmed:
        return Icons.check_circle;
      case models.NotificationType.bookingReminder:
        return Icons.alarm;
      case models.NotificationType.bookingCanceled:
        return Icons.cancel;
      case models.NotificationType.bookingExpired:
        return Icons.access_time;
      case models.NotificationType.noShow:
        return Icons.person_off;
      case models.NotificationType.noShowAlert:
        return Icons.person_off;
      case models.NotificationType.checkInReminder:
        return Icons.qr_code_scanner;
      case models.NotificationType.resourceCreated:
        return Icons.add_circle;
      case models.NotificationType.resourceDeleted:
        return Icons.remove_circle;
      case models.NotificationType.policyCreated:
        return Icons.policy;
      case models.NotificationType.policyUpdated:
        return Icons.update;
      case models.NotificationType.policyDeleted:
        return Icons.delete_outline;
      case models.NotificationType.system:
        return Icons.info;
    }
  }

  Color _getNotificationColor(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.bookingConfirmed:
        return Colors.green;
      case models.NotificationType.bookingReminder:
        return Colors.blue;
      case models.NotificationType.bookingCanceled:
        return Colors.orange;
      case models.NotificationType.bookingExpired:
        return Colors.red;
      case models.NotificationType.noShow:
        return Colors.red;
      case models.NotificationType.noShowAlert:
        return Colors.red;
      case models.NotificationType.checkInReminder:
        return Colors.blue;
      case models.NotificationType.resourceCreated:
        return Colors.green;
      case models.NotificationType.resourceDeleted:
        return Colors.orange;
      case models.NotificationType.policyCreated:
        return Colors.blue;
      case models.NotificationType.policyUpdated:
        return Colors.purple;
      case models.NotificationType.policyDeleted:
        return Colors.red;
      case models.NotificationType.system:
        return Colors.grey;
    }
  }
}

