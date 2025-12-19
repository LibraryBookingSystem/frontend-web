import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../constants/route_names.dart';
import '../../core/utils/responsive.dart';
import 'booking_card.dart';
import '../common/empty_state.dart';

/// Widget for displaying a list of bookings
class BookingsListWidget extends StatelessWidget {
  final List<Booking> bookings;
  final VoidCallback onRefresh;

  const BookingsListWidget({
    super.key,
    required this.bookings,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyBookingsState(
        onCreateBooking: () {
          Navigator.pushNamed(context, RouteNames.createBooking);
        },
      );
    }

    return Responsive.isMobile(context)
        ? ListView.builder(
            padding: Responsive.getPadding(context),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: Responsive.getSpacing(context,
                      mobile: 12, tablet: 16, desktop: 16),
                ),
                child: BookingCard(
                  booking: booking,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RouteNames.bookingDetails,
                      arguments: booking.id,
                    );
                  },
                  onCancel: () {
                    _showCancelDialog(context, booking);
                  },
                  onCheckIn: booking.canCheckIn()
                      ? () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.checkIn,
                            arguments: booking.id,
                          );
                        }
                      : null,
                ),
              );
            },
          )
        : ResponsiveLayout(
            child: ResponsiveGrid(
              mobileColumns: 1,
              tabletColumns: 2,
              desktopColumns: 3,
              spacing: Responsive.getSpacing(context,
                  mobile: 12, tablet: 16, desktop: 20),
              runSpacing: Responsive.getSpacing(context,
                  mobile: 12, tablet: 16, desktop: 20),
              children: bookings.asMap().entries.map((entry) {
                final index = entry.key;
                final booking = entry.value;
                return BookingCard(
                  booking: booking,
                  index: index,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RouteNames.bookingDetails,
                      arguments: booking.id,
                    );
                  },
                  onCancel: () {
                    _showCancelDialog(context, booking);
                  },
                  onCheckIn: booking.canCheckIn()
                      ? () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.checkIn,
                            arguments: booking.id,
                          );
                        }
                      : null,
                );
              }).toList(),
            ),
          );
  }

  void _showCancelDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: Text(
              'Are you sure you want to cancel your booking for ${booking.resourceName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final bookingProvider =
                    Provider.of<BookingProvider>(context, listen: false);
                await bookingProvider.cancelBooking(booking.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking canceled')),
                  );
                }
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
