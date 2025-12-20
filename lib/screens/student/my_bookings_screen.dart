import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/realtime_provider.dart';
import '../../widgets/bookings/bookings_list_widget.dart';
import '../../widgets/bookings/bookings_loading_widget.dart';
import '../../models/booking.dart';
import '../../widgets/common/theme_switcher.dart';

/// My bookings screen showing user's bookings
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeRealtimeUpdates();
      _loadBookings();
    });
  }

  void _initializeRealtimeUpdates() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final realtimeProvider =
        Provider.of<RealtimeProvider>(context, listen: false);

    final user = authProvider.currentUser;
    if (user != null) {
      // Initialize real-time booking updates
      bookingProvider.initializeRealtimeUpdates(realtimeProvider, user.id);

      // Connect to WebSocket if not already connected
      if (!realtimeProvider.isConnected) {
        realtimeProvider.connect();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

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
        actions: const [
          ThemeSwitcherIcon(),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ongoing'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
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
              return const BookingsLoadingWidget();
            }

            // Debug: Log all bookings
            debugPrint('🔍 DEBUG: MyBookingsScreen - Total bookings: ${bookingProvider.userBookings.length}');
            for (var b in bookingProvider.userBookings) {
              debugPrint('  Booking ${b.id}: ${b.resourceName}, ${b.startTime} to ${b.endTime}, status=${b.status.value}');
              debugPrint('    isCurrent=${b.isCurrent}, isUpcoming=${b.isUpcoming}, isPast=${b.isPast}');
            }

            final ongoingBookings = bookingProvider.userBookings
                .where((b) => b.isCurrent && b.status != BookingStatus.canceled)
                .toList();
            final upcomingBookings = bookingProvider.userBookings
                .where((b) => b.isUpcoming && !b.isCurrent && b.status != BookingStatus.canceled)
                .toList();
            final completedBookings = bookingProvider.userBookings
                .where((b) => b.status == BookingStatus.completed)
                .toList();
            final pastBookings = bookingProvider.userBookings
                .where((b) => b.isPast && 
                    b.status != BookingStatus.canceled && 
                    b.status != BookingStatus.completed)
                .toList();
            final canceledBookings = bookingProvider.userBookings
                .where((b) => b.status == BookingStatus.canceled)
                .toList();

            debugPrint('🔍 DEBUG: Filtered bookings - Ongoing: ${ongoingBookings.length}, Upcoming: ${upcomingBookings.length}, Completed: ${completedBookings.length}, Past: ${pastBookings.length}, Canceled: ${canceledBookings.length}');

            return TabBarView(
              controller: _tabController,
              children: [
                // Ongoing bookings (currently active)
                BookingsListWidget(
                  bookings: ongoingBookings,
                  onRefresh: _loadBookings,
                ),
                // Upcoming bookings (future bookings)
                BookingsListWidget(
                  bookings: upcomingBookings,
                  onRefresh: _loadBookings,
                ),
                // Completed bookings (successfully completed)
                BookingsListWidget(
                  bookings: completedBookings,
                  onRefresh: _loadBookings,
                ),
                // Past bookings (other past statuses like NO_SHOW)
                BookingsListWidget(
                  bookings: pastBookings,
                  onRefresh: _loadBookings,
                ),
                // Canceled bookings
                BookingsListWidget(
                  bookings: canceledBookings,
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
