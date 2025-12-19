import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../common/animated_card.dart';
import '../../core/animations/animation_utils.dart';
import '../../theme/app_theme.dart';

/// Booking card widget displaying booking information with animations
class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onCheckIn;
  final int? index; // For staggered animations

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onCancel,
    this.onCheckIn,
    this.index,
  });

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppTheme.warningColor;
      case BookingStatus.confirmed:
        return AppTheme.infoColor;
      case BookingStatus.checkedIn:
        return AppTheme.successColor;
      case BookingStatus.canceled:
        return AppTheme.errorColor;
      case BookingStatus.completed:
        return AppTheme.successColor;
      case BookingStatus.noShow:
        return AppTheme.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(booking.status);

    Widget card = AnimatedCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    statusColor.withValues(alpha: 0.2),
                    statusColor.withValues(alpha: 0.12),
                    statusColor.withValues(alpha: 0.08),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    statusColor.withValues(alpha: 0.08),
                    statusColor.withValues(alpha: 0.04),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.resourceName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Booking ID: #${booking.id}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: booking.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Time information
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: isDark ? statusColor : Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  date_utils.AppDateUtils.formatDate(
                                      booking.startTime),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.grey[200] : null,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 18,
                                color: isDark ? statusColor : Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${date_utils.AppDateUtils.formatTime(booking.startTime)} - ${date_utils.AppDateUtils.formatTime(booking.endTime)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.grey[700],
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 18,
                                color: isDark ? statusColor : Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Duration: ${date_utils.AppDateUtils.formatDuration(booking.duration)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (booking.isUpcoming &&
                        booking.timeUntilStart != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.infoColor
                              .withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.infoColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.alarm,
                              size: 16,
                              color: AppTheme.infoColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Starts in ${date_utils.AppDateUtils.formatTimeRemaining(booking.startTime)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.infoColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (booking.qrCode != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.purpleColor
                              .withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.purpleColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.purpleColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.qr_code,
                                size: 18,
                                color: AppTheme.purpleColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'QR Code',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                          fontSize: 11,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.qrCode!
                                        .substring(0, 8)
                                        .toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.purpleColor,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Action buttons
                    if (onCancel != null || onCheckIn != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onCheckIn != null && booking.canCheckIn()) ...[
                            ElevatedButton.icon(
                              onPressed: onCheckIn,
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text('Check In'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (onCancel != null && booking.canCancel)
                            OutlinedButton.icon(
                              onPressed: onCancel,
                              icon: const Icon(Icons.cancel, size: 18),
                              label: const Text('Cancel'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    // Apply staggered animation if index is provided
    if (index != null) {
      return AnimationUtils.staggeredFadeIn(
        index: index!,
        child: card,
      );
    }

    return AnimationUtils.fadeIn(child: card);
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case BookingStatus.pending:
        color = AppTheme.warningColor;
        label = 'Pending';
        break;
      case BookingStatus.confirmed:
        color = AppTheme.infoColor;
        label = 'Confirmed';
        break;
      case BookingStatus.checkedIn:
        color = AppTheme.successColor;
        label = 'Checked In';
        break;
      case BookingStatus.completed:
        color = AppTheme.successColor;
        label = 'Completed';
        break;
      case BookingStatus.canceled:
        color = AppTheme.errorColor;
        label = 'Canceled';
        break;
      case BookingStatus.noShow:
        color = AppTheme.warningColor;
        label = 'No Show';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
