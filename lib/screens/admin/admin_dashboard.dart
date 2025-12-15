import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resource_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/policy_provider.dart';
import '../../providers/notification_provider.dart';
import '../../constants/route_names.dart';
import '../../widgets/common/theme_switcher.dart';
import '../../widgets/notifications/notifications_menu.dart';
import '../../core/utils/responsive.dart';
import '../../core/animations/animation_utils.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/animated_card.dart';

/// Admin dashboard screen
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final resourceProvider =
        Provider.of<ResourceProvider>(context, listen: false);
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final policyProvider = Provider.of<PolicyProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    resourceProvider.loadResources();
    bookingProvider.loadAllBookings();
    policyProvider.loadActivePolicies();
    
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
        title: const Text('Admin Dashboard'),
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
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: ResponsiveLayout(
          child: SingleChildScrollView(
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
                                        Icons.admin_panel_settings,
                                        color: AppTheme.primaryColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Welcome, ${user?.username ?? 'Admin'}!',
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
                                  'System Administration',
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
                // Key metrics
                Text(
                  'Key Metrics',
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
                Consumer3<ResourceProvider, BookingProvider, PolicyProvider>(
                  builder: (context, resourceProvider, bookingProvider,
                      policyProvider, _) {
                    return ResponsiveGrid(
                      mobileColumns: 2,
                      tabletColumns: 2,
                      desktopColumns: 4,
                      spacing: Responsive.getSpacing(context,
                          mobile: 12, tablet: 16, desktop: 20),
                      runSpacing: Responsive.getSpacing(context,
                          mobile: 12, tablet: 16, desktop: 20),
                      children: [
                        _MetricCard(
                          title: 'Total Resources',
                          value: resourceProvider.resources.length.toString(),
                          icon: Icons.inventory_2,
                          color: AppTheme.infoColor,
                          index: 0,
                        ),
                        _MetricCard(
                          title: 'Total Bookings',
                          value: bookingProvider.bookings.length.toString(),
                          icon: Icons.event,
                          color: AppTheme.successColor,
                          index: 1,
                        ),
                        _MetricCard(
                          title: 'Active Policies',
                          value:
                              policyProvider.activePolicies.length.toString(),
                          icon: Icons.policy,
                          color: AppTheme.warningColor,
                          index: 2,
                        ),
                        _MetricCard(
                          title: 'System Status',
                          value: 'Online',
                          icon: Icons.check_circle,
                          color: AppTheme.successColor,
                          index: 3,
                        ),
                      ],
                    );
                  },
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
                      icon: Icons.inventory_2,
                      title: 'Manage Resources',
                      color: AppTheme.infoColor,
                      index: 0,
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouteNames.resourceManagement);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.policy,
                      title: 'Configure Policies',
                      color: AppTheme.warningColor,
                      index: 1,
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.policyConfig);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.people,
                      title: 'Manage Users',
                      color: AppTheme.purpleColor,
                      index: 2,
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.userManagement);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.analytics,
                      title: 'View Analytics',
                      color: AppTheme.successColor,
                      index: 3,
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.analytics);
                      },
                    ),
                  ],
                ),
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
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Admin Menu',
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
            leading: const Icon(Icons.inventory_2),
            title: const Text('Manage Resources'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.resourceManagement);
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Configure Policies'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.policyConfig);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Users'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.userManagement);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.analytics);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Audit Logs'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.auditLogs);
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int? index;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget card = AnimatedCard(
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.35),
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.15),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.1),
                    color.withValues(alpha: 0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: 2,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? color.withValues(alpha: 0.15)
                      : color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 24,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.grey[300]
                            : Colors.grey[600],
                        fontSize: 11,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    if (index != null) {
      return AnimationUtils.staggeredFadeIn(index: index!, child: card);
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
    Widget card = AnimatedCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.1),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.1),
                    color.withValues(alpha: 0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(
                  color: color.withValues(alpha: 0.25),
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
                  color: isDark
                      ? color.withValues(alpha: 0.15)
                      : color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
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
