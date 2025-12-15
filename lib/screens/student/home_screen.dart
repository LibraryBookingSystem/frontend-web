import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/notification_provider.dart';
import '../../constants/route_names.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../widgets/common/theme_switcher.dart';
import '../../widgets/notifications/notifications_menu.dart';
import '../../widgets/common/animated_card.dart';
import '../../core/animations/animation_utils.dart';
import '../../theme/app_theme.dart';
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
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return AnimationUtils.fadeIn(
                      child: AnimatedCard(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primaryColor.withValues(alpha: 0.2),
                                      AppTheme.secondaryColor.withValues(alpha: 0.15),
                                      AppTheme.purpleColor.withValues(alpha: 0.1),
                                    ],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            border: isDark
                                ? Border.all(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
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
                                            ? AppTheme.primaryColor.withValues(alpha: 0.12)
                                            : AppTheme.primaryColor.withValues(alpha: 0.1),
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
                ResponsiveBuilder(
                  mobile: Column(
                    children: [
                      _StatCard(
                        icon: Icons.event,
                        label: 'Upcoming',
                        value: _getUpcomingBookingsCount(),
                        index: 0,
                      ),
                      SizedBox(
                          height: Responsive.getSpacing(context,
                              mobile: 12, tablet: 16, desktop: 16)),
                      _StatCard(
                        icon: Icons.notifications,
                        label: 'Notifications',
                        value: _getUnreadCount(),
                        index: 1,
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
                      color: AppTheme.infoColor,
                      index: 0,
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouteNames.browseResources);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.map,
                      title: 'Floor Plan',
                      color: AppTheme.successColor,
                      index: 1,
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.floorPlan);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.add_circle,
                      title: 'Create Booking',
                      color: AppTheme.warningColor,
                      index: 2,
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.createBooking);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.event_note,
                      title: 'My Bookings',
                      color: AppTheme.purpleColor,
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
  final int? index;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.index,
  });

  Color _getCardColor(BuildContext context) {
    if (label.toLowerCase().contains('upcoming')) {
      return AppTheme.infoColor; // Blue for upcoming bookings
    } else if (label.toLowerCase().contains('notification')) {
      return AppTheme.secondaryColor; // Pink for notifications
    }
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = _getCardColor(context);
    
    Widget card = AnimatedCard(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    cardColor.withValues(alpha: 0.12),
                    cardColor.withValues(alpha: 0.08),
                    cardColor.withValues(alpha: 0.05),
                  ]
                : [
                    cardColor.withValues(alpha: 0.1),
                    cardColor.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(
                  color: cardColor.withValues(alpha: 0.2),
                  width: 1,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? cardColor.withValues(alpha: 0.15)
                      : cardColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: cardColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );

    if (index != null) {
      return AnimationUtils.staggeredFadeIn(
        index: index!,
        child: card,
      );
    }

    return AnimationUtils.fadeIn(child: card);
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final int? index;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              color,
              color.withValues(alpha: 0.8), // More vibrant in dark mode
              color.withValues(alpha: 0.6),
            ]
          : [
              color,
              color.withValues(alpha: 0.7),
            ],
    );

    Widget card = AnimatedCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (index != null) {
      return AnimationUtils.staggeredFadeIn(
        index: index!,
        child: card,
      );
    }

    return AnimationUtils.fadeIn(child: card);
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
