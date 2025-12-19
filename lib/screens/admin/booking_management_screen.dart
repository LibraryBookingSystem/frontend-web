import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/resource_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../core/mixins/error_handling_mixin.dart';
import '../../models/booking.dart';
import '../../models/resource.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../theme/app_theme.dart';

/// Booking management screen for admins
/// Shows all bookings with user info and allows cancellation
class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen>
    with ErrorHandlingMixin {
  String _statusFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    await bookingProvider.loadAllBookings();
  }

  List<Booking> _filterBookings(List<Booking> bookings) {
    var filtered = bookings;

    // Filter by status
    if (_statusFilter != 'ALL') {
      filtered =
          filtered.where((b) => b.status.value == _statusFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((b) {
        final userName = b.userName?.toLowerCase() ?? '';
        final userEmail = b.userEmail?.toLowerCase() ?? '';
        final resourceName = b.resourceName.toLowerCase();
        return userName.contains(query) ||
            userEmail.contains(query) ||
            resourceName.contains(query);
      }).toList();
    }

    // Sort by start time (most recent first)
    filtered.sort((a, b) => b.startTime.compareTo(a.startTime));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by user or resource...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All Status')),
                    DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'CONFIRMED', child: Text('Confirmed')),
                    DropdownMenuItem(
                        value: 'CHECKED_IN', child: Text('Checked In')),
                    DropdownMenuItem(
                        value: 'COMPLETED', child: Text('Completed')),
                    DropdownMenuItem(
                        value: 'CANCELED', child: Text('Canceled')),
                    DropdownMenuItem(value: 'NO_SHOW', child: Text('No Show')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _statusFilter = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          // Bookings list
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, bookingProvider, _) {
                if (bookingProvider.isLoading) {
                  return const LoadingIndicator();
                }

                if (bookingProvider.error != null) {
                  return ErrorDisplayWidget(
                    message: bookingProvider.error!,
                    onRetry: () {
                      bookingProvider.clearError();
                      _loadBookings();
                    },
                  );
                }

                final bookings = _filterBookings(bookingProvider.bookings);

                if (bookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _statusFilter != 'ALL'
                              ? 'No bookings match your filters'
                              : 'No bookings found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    itemCount: bookings.length,
                    padding: Responsive.getPadding(context),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _buildBookingCard(booking);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final statusColor = _getStatusColor(booking.status);
    final canCancel = booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed ||
        booking.status == BookingStatus.checkedIn;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          booking.resourceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.userName ?? 'User ${booking.userId}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              '${date_utils.AppDateUtils.formatDateTimeDisplay(booking.startTime)} - ${date_utils.AppDateUtils.formatTime(booking.endTime)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                booking.status.value.replaceAll('_', ' '),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                ),
              ),
              backgroundColor: statusColor.withValues(alpha: 0.1),
              side: BorderSide.none,
            ),
            if (canCancel)
              IconButton(
                icon: const Icon(Icons.cancel, color: AppTheme.errorColor),
                tooltip: 'Cancel Booking',
                onPressed: () => _showCancelDialog(booking),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.person, 'User ID', '${booking.userId}'),
                if (booking.userName != null)
                  _buildDetailRow(Icons.badge, 'Name', booking.userName!),
                if (booking.userEmail != null && booking.userEmail!.isNotEmpty)
                  _buildDetailRow(Icons.email, 'Email', booking.userEmail!),
                _buildDetailRow(
                    Icons.meeting_room, 'Resource', booking.resourceName),
                _buildDetailRow(
                    Icons.qr_code, 'QR Code', booking.qrCode ?? 'N/A'),
                _buildDetailRow(
                  Icons.schedule,
                  'Duration',
                  '${booking.duration.inMinutes} minutes',
                ),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Created',
                  date_utils.AppDateUtils.formatDateTimeDisplay(
                      booking.createdAt),
                ),
                if (booking.checkedInAt != null)
                  _buildDetailRow(
                    Icons.check_circle,
                    'Checked In',
                    date_utils.AppDateUtils.formatDateTimeDisplay(
                        booking.checkedInAt!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.amber;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkedIn:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.grey;
      case BookingStatus.canceled:
        return Colors.red;
      case BookingStatus.noShow:
        return Colors.orange;
    }
  }

  void _showCancelDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to cancel this booking?'),
              const SizedBox(height: 12),
              Text('Resource: ${booking.resourceName}'),
              Text('User: ${booking.userName ?? 'User ${booking.userId}'}'),
              Text(
                  'Time: ${date_utils.AppDateUtils.formatDateTimeDisplay(booking.startTime)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Booking'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _cancelBooking(booking);
              },
              child: const Text('Cancel Booking',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelBooking(Booking booking) async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    final success = await bookingProvider.cancelBooking(booking.id);

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (success) {
        // Update resource availability to available
        final resourceProvider =
            Provider.of<ResourceProvider>(context, listen: false);
        resourceProvider.updateResourceAvailability(
            booking.resourceId, ResourceStatus.available);
        resourceProvider.syncResourceWithRealtime(
            booking.resourceId, 'available');

        showSuccessSnackBar(context, 'Booking canceled successfully');
        _loadBookings();
      } else {
        // Parse error message for better display
        String errorMessage =
            bookingProvider.error ?? 'Failed to cancel booking';

        // Check if it's a "not found" error - might be a stale booking
        if (errorMessage.contains('not found') ||
            errorMessage.contains('Booking not found')) {
          errorMessage =
              'Booking may have already been deleted. Refreshing list...';
          _loadBookings();
        }

        showErrorSnackBar(context, errorMessage);
      }
    }
  }
}
