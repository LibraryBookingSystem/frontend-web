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
    _tabController = TabController(length: 3, vsync: this);
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
        actions: [
          ThemeSwitcherIcon(),
        ],
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
              return const BookingsLoadingWidget();
            }

            return TabBarView(
              controller: _tabController,
              children: [
                BookingsListWidget(
                  bookings: bookingProvider.userBookings
                      .where((b) =>
                          b.isUpcoming && b.status != BookingStatus.canceled)
                      .toList(),
                  onRefresh: _loadBookings,
                ),
                BookingsListWidget(
                  bookings: bookingProvider.userBookings
                      .where(
                          (b) => b.isPast && b.status != BookingStatus.canceled)
                      .toList(),
                  onRefresh: _loadBookings,
                ),
                BookingsListWidget(
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
