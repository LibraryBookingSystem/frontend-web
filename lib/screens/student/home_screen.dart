import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';
import '../../providers/notification_provider.dart';
import '../../constants/route_names.dart';
import '../../widgets/common/theme_switcher.dart';
import '../../widgets/notifications/notifications_menu.dart';
import '../../widgets/common/animated_card.dart';
import '../../core/animations/animation_utils.dart';
import '../../theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'home/stat_card.dart';
import 'home/action_card.dart';
import 'home/upcoming_bookings_preview.dart';

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
                      showDialog(
                        context: context,
                        builder: (context) => const NotificationsMenu(),
                      );
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
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    return AnimationUtils.fadeIn(
                      child: AnimatedCard(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primaryColor
                                          .withValues(alpha: 0.2),
                                      AppTheme.secondaryColor
                                          .withValues(alpha: 0.15),
                                      AppTheme.purpleColor
                                          .withValues(alpha: 0.1),
                                    ],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            border: isDark
                                ? Border.all(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.3),
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Padding(
                            padding: Responsive.getCardPadding(context),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppTheme.primaryColor
                                                .withValues(alpha: 0.12)
                                            : AppTheme.primaryColor
                                                .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.waving_hand,
                                        color: AppTheme.primaryColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Welcome, ${user?.username ?? 'Student'}!',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Find and book your study space',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                    height: Responsive.getSpacing(context,
                        mobile: 20, tablet: 24, desktop: 28)),
                // Quick stats
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.event,
                        label: 'Upcoming',
                        value: _getUpcomingBookingsCount(),
                        index: 0,
                      ),
                    ),
                    SizedBox(
                        width: Responsive.getSpacing(context,
                            mobile: 8, tablet: 16, desktop: 20)),
                    Expanded(
                      child: StatCard(
                        icon: Icons.notifications,
                        label: 'Notifications',
                        value: _getUnreadCount(),
                        index: 1,
                      ),
                    ),
                  ],
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
                    ActionCard(
                      icon: Icons.search,
                      title: 'Browse Resources',
                      color: const Color(0xFF4ECDC4),
                      index: 0,
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouteNames.browseResources);
                      },
                    ),
                    ActionCard(
                      icon: Icons.map,
                      title: 'Floor Plan',
                      color: const Color(0xFF4CAF50),
                      index: 1,
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.floorPlan);
                      },
                    ),
                    ActionCard(
                      icon: Icons.add_circle,
                      title: 'Create Booking',
                      color: const Color(0xFFFF9800),
                      index: 2,
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.createBooking);
                      },
                    ),
                    ActionCard(
                      icon: Icons.event_note,
                      title: 'My Bookings',
                      color: const Color(0xFF9C27B0),
                      index: 3,
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
                const UpcomingBookingsPreview(),
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
    final upcoming = bookingProvider.userBookings
        .where((b) => b.isUpcoming && b.status != BookingStatus.canceled)
        .length;
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
