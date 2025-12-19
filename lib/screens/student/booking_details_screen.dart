import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/resource_provider.dart';
import '../../widgets/bookings/qr_code_display.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../models/booking.dart';
import '../../models/resource.dart';
import '../../core/mixins/error_handling_mixin.dart';
import '../../constants/route_names.dart';
import '../../widgets/common/theme_switcher.dart';

/// Booking details screen
class BookingDetailsScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen>
    with ErrorHandlingMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBooking();
    });
  }

  void _loadBooking() {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.getBookingById(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          ThemeSwitcherIcon(),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          final booking = bookingProvider.selectedBooking ??
              bookingProvider.userBookings.firstWhere(
                (b) => b.id == widget.bookingId,
                orElse: () => bookingProvider.bookings.firstWhere(
                  (b) => b.id == widget.bookingId,
                ),
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Booking information card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.resourceName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          icon: Icons.room,
                          label: 'Room Name',
                          value: booking.resourceName,
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.access_time,
                          label: 'Start Time',
                          value: date_utils.AppDateUtils.formatDateTimeDisplay(
                              booking.startTime),
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.schedule,
                          label: 'End Time',
                          value: date_utils.AppDateUtils.formatDateTimeDisplay(
                              booking.endTime),
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.timer,
                          label: 'Duration',
                          value: date_utils.AppDateUtils.formatDuration(
                              booking.duration),
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.info,
                          label: 'Status',
                          value: booking.status.value,
                        ),
                        if (booking.checkedInAt != null) ...[
                          const SizedBox(height: 8),
                          _DetailRow(
                            icon: Icons.check_circle,
                            label: 'Checked In At',
                            value:
                                date_utils.AppDateUtils.formatDateTimeDisplay(
                                    booking.checkedInAt!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // QR Code display
                if (booking.qrCode != null &&
                    booking.status == BookingStatus.confirmed)
                  QRCodeDisplay(booking: booking),
                const SizedBox(height: 16),
                // Action buttons
                if (booking.canCheckIn()) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        RouteNames.checkIn,
                        arguments: booking.id,
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Check In'),
                  ),
                  const SizedBox(height: 8),
                ],
                if (booking.canCancel) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      _showCancelDialog(context, booking);
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel Booking'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context, booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isCanceling = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Cancel Booking'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Are you sure you want to cancel your booking for ${booking.resourceName}?'),
                  if (isCanceling) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isCanceling ? null : () => Navigator.pop(dialogContext),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: isCanceling
                      ? null
                      : () async {
                          setDialogState(() {
                            isCanceling = true;
                          });
                          final bookingProvider = Provider.of<BookingProvider>(
                              context,
                              listen: false);
                          final success =
                              await bookingProvider.cancelBooking(booking.id);
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (context.mounted) {
                            if (success) {
                              // Update resource availability to available
                              final resourceProvider =
                                  Provider.of<ResourceProvider>(context,
                                      listen: false);
                              resourceProvider.updateResourceAvailability(
                                  booking.resourceId, ResourceStatus.available);
                              resourceProvider.syncResourceWithRealtime(
                                  booking.resourceId, 'available');

                              showSuccessSnackBar(
                                  context, 'Booking canceled successfully');
                              // Navigate to home screen
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                RouteNames.studentHome,
                                (route) => false,
                              );
                            } else {
                              showErrorSnackBar(
                                  context,
                                  bookingProvider.error ??
                                      'Failed to cancel booking');
                            }
                          }
                        },
                  child: Text(
                    isCanceling ? 'Canceling...' : 'Yes, Cancel',
                    style: TextStyle(
                        color: isCanceling ? Colors.grey : Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
