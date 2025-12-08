import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bookings/booking_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../models/booking.dart';
import '../../constants/route_names.dart';
import '../../core/utils/responsive.dart';

/// My bookings screen showing user's bookings
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  
  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _loadBookings() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    final user = authProvider.currentUser;
    if (user != null) {
      bookingProvider.loadUserBookings(user.id);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Canceled'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadBookings();
        },
        child: Consumer<BookingProvider>(
          builder: (context, bookingProvider, _) {
            if (bookingProvider.isLoading) {
              return const LoadingIndicator();
            }
            
            return TabBarView(
              controller: _tabController,
              children: [
                _BookingsList(
                  bookings: bookingProvider.userBookings
                      .where((b) => b.isUpcoming && b.status != BookingStatus.canceled)
                      .toList(),
                  onRefresh: _loadBookings,
                ),
                _BookingsList(
                  bookings: bookingProvider.userBookings
                      .where((b) => b.isPast && b.status != BookingStatus.canceled)
                      .toList(),
                  onRefresh: _loadBookings,
                ),
                _BookingsList(
                  bookings: bookingProvider.userBookings
                      .where((b) => b.status == BookingStatus.canceled)
                      .toList(),
                  onRefresh: _loadBookings,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final List<Booking> bookings;
  final VoidCallback onRefresh;
  
  const _BookingsList({
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
                  bottom: Responsive.getSpacing(context, mobile: 12, tablet: 16, desktop: 16),
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
              spacing: Responsive.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
              runSpacing: Responsive.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
              children: bookings.map((booking) {
                return BookingCard(
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
          content: Text('Are you sure you want to cancel your booking for ${booking.resourceName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
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

