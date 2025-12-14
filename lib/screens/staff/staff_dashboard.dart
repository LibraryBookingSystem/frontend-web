import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../constants/route_names.dart';
import '../../widgets/common/theme_switcher.dart';
import '../../widgets/notifications/notifications_menu.dart';
import '../../widgets/common/animated_card.dart';
import '../../core/animations/animation_utils.dart';
import '../../theme/app_theme.dart';
import '../../core/utils/responsive.dart';

/// Staff dashboard screen
class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final user = authProvider.currentUser;
    if (user != null) {
      notificationProvider.loadNotifications(user.id);
      notificationProvider.loadUnreadCount(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
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
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                                  AppTheme.primaryColor.withValues(alpha: 0.08),
                                  AppTheme.secondaryColor.withValues(alpha: 0.05),
                                ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(20),
                        border: isDark
                            ? Border.all(
                                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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
                                  child: Icon(
                                    Icons.work,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Welcome, ${user?.username ?? 'Staff'}!',
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
                              'Staff Dashboard',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            const SizedBox(height: 24),
            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ResponsiveGrid(
              mobileColumns: 2,
              tabletColumns: 2,
              desktopColumns: 4,
              spacing: Responsive.getSpacing(context,
                  mobile: 12, tablet: 16, desktop: 20),
              runSpacing: Responsive.getSpacing(context,
                  mobile: 12, tablet: 16, desktop: 20),
              children: [
                _ActionCard(
                  icon: Icons.dashboard,
                  title: 'Occupancy Overview',
                  color: AppTheme.infoColor,
                  index: 0,
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.occupancyOverview);
                  },
                ),
                _ActionCard(
                  icon: Icons.check_circle,
                  title: 'Manual Check-In',
                  color: AppTheme.successColor,
                  index: 1,
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.manualCheckIn);
                  },
                ),
                _ActionCard(
                  icon: Icons.search,
                  title: 'Browse Resources',
                  color: AppTheme.warningColor,
                  index: 2,
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.browseResources);
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
            const SizedBox(height: 24),
            // Occupancy overview card
            AnimationUtils.fadeIn(
              child: AnimatedCard(
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.occupancyOverview);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: Theme.of(context).brightness == Brightness.dark
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.infoColor.withValues(alpha: 0.12),
                              AppTheme.infoColor.withValues(alpha: 0.08),
                              AppTheme.infoColor.withValues(alpha: 0.05),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.infoColor.withValues(alpha: 0.08),
                              AppTheme.infoColor.withValues(alpha: 0.04),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    border: Theme.of(context).brightness == Brightness.dark
                        ? Border.all(
                            color: AppTheme.infoColor.withValues(alpha: 0.2),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.infoColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.dashboard,
                            size: 32,
                            color: AppTheme.infoColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Occupancy Overview',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'View real-time occupancy statistics',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Staff Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Occupancy Overview'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.occupancyOverview);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Manual Check-In'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.manualCheckIn);
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
            onTap: () {
              _handleLogout(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
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
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.1),
            ]
          : [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
    );

    Widget card = AnimatedCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
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
