import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resource_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/policy_provider.dart';
import '../../constants/route_names.dart';
import '../../widgets/common/theme_switcher.dart';
import '../../core/utils/responsive.dart';

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

    resourceProvider.loadResources();
    bookingProvider.loadAllBookings();
    policyProvider.loadActivePolicies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: const [
          ThemeSwitcherIcon(),
          SizedBox(width: 8),
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
                    return Card(
                      child: Padding(
                        padding: Responsive.getCardPadding(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user?.username ?? 'Admin'}!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'System Administration',
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
                          color: Colors.blue,
                        ),
                        _MetricCard(
                          title: 'Total Bookings',
                          value: bookingProvider.bookings.length.toString(),
                          icon: Icons.event,
                          color: Colors.green,
                        ),
                        _MetricCard(
                          title: 'Active Policies',
                          value:
                              policyProvider.activePolicies.length.toString(),
                          icon: Icons.policy,
                          color: Colors.orange,
                        ),
                        const _MetricCard(
                          title: 'System Status',
                          value: 'Online',
                          icon: Icons.check_circle,
                          color: Colors.green,
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
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouteNames.resourceManagement);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.policy,
                      title: 'Configure Policies',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.policyConfig);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.people,
                      title: 'Manage Users',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.userManagement);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.analytics,
                      title: 'View Analytics',
                      color: Colors.green,
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

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
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
