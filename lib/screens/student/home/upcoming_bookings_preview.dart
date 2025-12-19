import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../models/booking.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../constants/route_names.dart';

/// Preview widget showing upcoming bookings on the home screen
class UpcomingBookingsPreview extends StatelessWidget {
  const UpcomingBookingsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        if (bookingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final upcoming = bookingProvider.userBookings
            .where((b) => b.isUpcoming && b.status != BookingStatus.canceled)
            .take(3)
            .toList();

        if (upcoming.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('No upcoming bookings'),
              ),
            ),
          );
        }

        return Column(
          children: upcoming.map((booking) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.event),
                title: Text(booking.resourceName),
                subtitle: Text(
                  '${date_utils.AppDateUtils.formatDateTimeDisplay(booking.startTime)} - ${date_utils.AppDateUtils.formatTime(booking.endTime)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.bookingDetails,
                    arguments: booking.id,
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
