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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.resourceName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.access_time,
                      size: 16,
                      color: isDark ? statusColor : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${date_utils.AppDateUtils.formatDateTimeDisplay(booking.startTime)} - ${date_utils.AppDateUtils.formatTime(booking.endTime)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[200] : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.schedule,
                      size: 16,
                      color: isDark ? statusColor : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Duration: ${date_utils.AppDateUtils.formatDuration(booking.duration)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (booking.isUpcoming && booking.timeUntilStart != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.infoColor.withValues(alpha: isDark ? 0.3 : 0.15),
                        AppTheme.infoColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: isDark
                        ? Border.all(
                            color: AppTheme.infoColor.withValues(alpha: 0.4),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.alarm,
                        size: 16,
                        color: isDark ? AppTheme.infoColor : AppTheme.infoColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Starts in ${date_utils.AppDateUtils.formatTimeRemaining(booking.startTime)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppTheme.infoColor : AppTheme.infoColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (booking.qrCode != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.purpleColor.withValues(alpha: isDark ? 0.25 : 0.15),
                        AppTheme.purpleColor.withValues(alpha: isDark ? 0.15 : 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: isDark
                        ? Border.all(
                            color: AppTheme.purpleColor.withValues(alpha: 0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.purpleColor.withValues(alpha: isDark ? 0.3 : 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.qr_code,
                          size: 16,
                          color: isDark ? AppTheme.purpleColor : AppTheme.purpleColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'QR: ${booking.qrCode!.substring(0, 8)}...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppTheme.purpleColor : AppTheme.purpleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (onCancel != null || onCheckIn != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onCheckIn != null && booking.canCheckIn())
                      TextButton.icon(
                        onPressed: onCheckIn,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Check In'),
                      ),
                    if (onCancel != null && booking.canCancel)
                      TextButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ],
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

