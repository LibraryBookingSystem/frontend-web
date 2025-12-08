import 'package:flutter/material.dart';

/// Empty state widget for displaying when lists are empty
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty resources state
class EmptyResourcesState extends StatelessWidget {
  final VoidCallback? onRefresh;
  
  const EmptyResourcesState({
    super.key,
    this.onRefresh,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inventory_2_outlined,
      message: 'No resources found.\nTry adjusting your filters.',
      actionLabel: 'Refresh',
      onAction: onRefresh,
    );
  }
}

/// Empty bookings state
class EmptyBookingsState extends StatelessWidget {
  final VoidCallback? onCreateBooking;
  
  const EmptyBookingsState({
    super.key,
    this.onCreateBooking,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.event_busy,
      message: 'No bookings found.\nCreate your first booking!',
      actionLabel: 'Create Booking',
      onAction: onCreateBooking,
    );
  }
}

/// Empty notifications state
class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.notifications_none,
      message: 'No notifications.\nYou\'re all caught up!',
    );
  }
}

