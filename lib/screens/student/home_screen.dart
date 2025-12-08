import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/notification_provider.dart';
import '../../constants/route_names.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../widgets/common/theme_switcher.dart';
import '../../core/utils/responsive.dart';

/// Student home screen (dashboard)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    final user = authProvider.currentUser;
    if (user != null) {
      bookingProvider.loadUserBookings(user.id);
      notificationProvider.loadNotifications(user.id);
      notificationProvider.loadUnreadCount(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Booking'),
        actions: [
          const ThemeSwitcherIcon(),
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      // Navigate to notifications
                    },
                  ),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${notificationProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: ResponsiveLayout(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final user = authProvider.currentUser;
                    return Card(
                      child: Padding(
                        padding: Responsive.getCardPadding(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user?.username ?? 'Student'}!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Find and book your study space',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                    height: Responsive.getSpacing(context,
                        mobile: 20, tablet: 24, desktop: 28)),
                // Quick stats
                ResponsiveBuilder(
                  mobile: Column(
                    children: [
                      _StatCard(
                        icon: Icons.event,
                        label: 'Upcoming',
                        value: _getUpcomingBookingsCount(),
                      ),
                      SizedBox(
                          height: Responsive.getSpacing(context,
                              mobile: 12, tablet: 16, desktop: 16)),
                      _StatCard(
                        icon: Icons.notifications,
                        label: 'Notifications',
                        value: _getUnreadCount(),
                      ),
                    ],
                  ),
                  tablet: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.event,
                          label: 'Upcoming',
                          value: _getUpcomingBookingsCount(),
                        ),
                      ),
                      SizedBox(
                          width: Responsive.getSpacing(context,
                              mobile: 12, tablet: 16, desktop: 20)),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.notifications,
                          label: 'Notifications',
                          value: _getUnreadCount(),
                        ),
                      ),
                    ],
                  ),
                  desktop: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.event,
                          label: 'Upcoming',
                          value: _getUpcomingBookingsCount(),
                        ),
                      ),
                      SizedBox(
                          width: Responsive.getSpacing(context,
                              mobile: 12, tablet: 16, desktop: 20)),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.notifications,
                          label: 'Notifications',
                          value: _getUnreadCount(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    height: Responsive.getSpacing(context,
                        mobile: 20, tablet: 24, desktop: 28)),
                // Quick actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.getFontSize(
                          context,
                          mobile: 20,
                          tablet: 22,
                          desktop: 24,
                        ),
                      ),
                ),
                SizedBox(
                    height: Responsive.getSpacing(context,
                        mobile: 12, tablet: 16, desktop: 20)),
                ResponsiveGrid(
                  mobileColumns: 2,
                  tabletColumns: 3,
                  desktopColumns: 4,
                  spacing: Responsive.getSpacing(context,
                      mobile: 12, tablet: 16, desktop: 20),
                  runSpacing: Responsive.getSpacing(context,
                      mobile: 12, tablet: 16, desktop: 20),
                  children: [
                    _ActionCard(
                      icon: Icons.search,
                      title: 'Browse Resources',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouteNames.browseResources);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.map,
                      title: 'Floor Plan',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.floorPlan);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.add_circle,
                      title: 'Create Booking',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.createBooking);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.event_note,
                      title: 'My Bookings',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.myBookings);
                      },
                    ),
                  ],
                ),
                SizedBox(
                    height: Responsive.getSpacing(context,
                        mobile: 20, tablet: 24, desktop: 28)),
                // Upcoming bookings preview
                Text(
                  'Upcoming Bookings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.getFontSize(
                          context,
                          mobile: 20,
                          tablet: 22,
                          desktop: 24,
                        ),
                      ),
                ),
                SizedBox(
                    height: Responsive.getSpacing(context,
                        mobile: 12, tablet: 16, desktop: 20)),
                _UpcomingBookingsPreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: Responsive.getDrawerWidth(context),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final user = authProvider.currentUser;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Text(
                        user?.username[0].toUpperCase() ?? 'U',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.username ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Browse Resources'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.browseResources);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Floor Plan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.floorPlan);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_note),
            title: const Text('My Bookings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.myBookings);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  String _getUpcomingBookingsCount() {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final upcoming =
        bookingProvider.userBookings.where((b) => b.isUpcoming).length;
    return upcoming.toString();
  }

  String _getUnreadCount() {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    return notificationProvider.unreadCount.toString();
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingBookingsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        if (bookingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final upcoming = bookingProvider.userBookings
            .where((b) => b.isUpcoming)
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
