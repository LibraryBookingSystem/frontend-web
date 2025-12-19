import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../core/mixins/error_handling_mixin.dart';
import '../../models/user.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/theme_switcher.dart';

/// User management screen for admins
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with ErrorHandlingMixin, SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.loadAllUsers();
    userProvider.loadPendingUsers();
    userProvider.loadRejectedUsers();
  }

  void _searchUsers(String query) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = [];
      });
      return;
    }

    setState(() {
      _filteredUsers = userProvider.users
          .where((user) =>
              user.username.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          ThemeSwitcherIcon(),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Users'),
            Tab(text: 'Pending Approvals'),
            Tab(icon: Icon(Icons.block), text: 'Rejected Users'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar (only for All Users tab)
          if (_tabController.index == 0)
            Padding(
              padding: Responsive.getPadding(context),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Users',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by username or email',
                ),
                onChanged: _searchUsers,
              ),
            ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllUsersTab(),
                _buildPendingUsersTab(),
                _buildRejectedUsersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllUsersTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (userProvider.error != null) {
          return ErrorDisplayWidget(
            message: userProvider.error!,
            onRetry: () {
              userProvider.clearError();
              _loadUsers();
            },
          );
        }

        final users = _searchController.text.isEmpty
            ? userProvider.users
            : _filteredUsers;

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _loadUsers();
          },
          child: Responsive.isMobile(context)
              ? ListView.builder(
                  itemCount: users.length,
                  padding: Responsive.getHorizontalPadding(context),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: EdgeInsets.only(
                        bottom: Responsive.getSpacing(context,
                            mobile: 8, tablet: 12, desktop: 16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Avatar
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: CircleAvatar(
                                child: Text(user.username[0].toUpperCase()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // User info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    user.username,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Role: ${user.role.value}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  if (user.pendingApproval)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Chip(
                                        label: const Text('Pending Approval'),
                                        backgroundColor: Colors.orange
                                            .withValues(alpha: 0.2),
                                        labelStyle: const TextStyle(
                                            color: Colors.orange),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                  if (user.rejected)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Chip(
                                        label: const Text('Rejected'),
                                        backgroundColor:
                                            Colors.red.withValues(alpha: 0.2),
                                        labelStyle:
                                            const TextStyle(color: Colors.red),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                  if (user.restricted)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Restricted: ${user.restrictionReason ?? "No reason"}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.red,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Trailing menu
                            PopupMenuButton<String>(
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              itemBuilder: (context) =>
                                  <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'restrict',
                                  enabled: !user.restricted,
                                  child: const Text('Restrict User'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'unrestrict',
                                  enabled: user.restricted,
                                  child: const Text('Unrestrict User'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'view',
                                  child: Text('View Details'),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete User',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'restrict') {
                                  _showRestrictDialog(context, user);
                                } else if (value == 'unrestrict') {
                                  _handleUnrestrict(context, user);
                                } else if (value == 'view') {
                                  _showUserDetails(context, user);
                                } else if (value == 'delete') {
                                  _showDeleteConfirmDialog(context, user);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : ResponsiveLayout(
                  child: ResponsiveGrid(
                    mobileColumns: 1,
                    tabletColumns: 2,
                    desktopColumns: 3,
                    spacing: Responsive.getSpacing(context,
                        mobile: 12, tablet: 16, desktop: 20),
                    runSpacing: Responsive.getSpacing(context,
                        mobile: 12, tablet: 16, desktop: 20),
                    children: users.map((user) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Avatar
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: CircleAvatar(
                                  child: Text(user.username[0].toUpperCase()),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // User info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      user.username,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.email,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Role: ${user.role.value}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    if (user.pendingApproval)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Chip(
                                          label: const Text('Pending Approval'),
                                          backgroundColor: Colors.orange
                                              .withValues(alpha: 0.2),
                                          labelStyle: const TextStyle(
                                              color: Colors.orange),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    if (user.rejected)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Chip(
                                          label: const Text('Rejected'),
                                          backgroundColor:
                                              Colors.red.withValues(alpha: 0.2),
                                          labelStyle: const TextStyle(
                                              color: Colors.red),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    if (user.restricted)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Restricted: ${user.restrictionReason ?? "No reason"}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.red,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Trailing menu
                              PopupMenuButton<String>(
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                itemBuilder: (context) =>
                                    <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'restrict',
                                    enabled: !user.restricted,
                                    child: const Text('Restrict User'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'unrestrict',
                                    enabled: user.restricted,
                                    child: const Text('Unrestrict User'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'view',
                                    child: Text('View Details'),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete User',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'restrict') {
                                    _showRestrictDialog(context, user);
                                  } else if (value == 'unrestrict') {
                                    _handleUnrestrict(context, user);
                                  } else if (value == 'view') {
                                    _showUserDetails(context, user);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmDialog(context, user);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildPendingUsersTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (userProvider.error != null) {
          return ErrorDisplayWidget(
            message: userProvider.error!,
            onRetry: () {
              userProvider.clearError();
              userProvider.loadPendingUsers();
            },
          );
        }

        final pendingUsers = userProvider.pendingUsers;

        if (pendingUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pending_actions, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No pending approvals',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            userProvider.loadPendingUsers();
          },
          child: Responsive.isMobile(context)
              ? ListView.builder(
                  itemCount: pendingUsers.length,
                  padding: Responsive.getHorizontalPadding(context),
                  itemBuilder: (context, index) {
                    final user = pendingUsers[index];
                    return Card(
                      margin: EdgeInsets.only(
                        bottom: Responsive.getSpacing(context,
                            mobile: 8, tablet: 12, desktop: 16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: CircleAvatar(
                                    child: Text(user.username[0].toUpperCase()),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // User info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        user.username,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.email,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Role: ${user.role.value}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _handleReject(context, user),
                                    icon: const Icon(Icons.close, size: 18),
                                    label: const Text('Reject'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _handleApprove(context, user),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('Approve'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : ResponsiveLayout(
                  child: ResponsiveGrid(
                    mobileColumns: 1,
                    tabletColumns: 2,
                    desktopColumns: 3,
                    spacing: Responsive.getSpacing(context,
                        mobile: 12, tablet: 16, desktop: 20),
                    runSpacing: Responsive.getSpacing(context,
                        mobile: 12, tablet: 16, desktop: 20),
                    children: pendingUsers.map((user) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: CircleAvatar(
                                      child:
                                          Text(user.username[0].toUpperCase()),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // User info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          user.username,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Role: ${user.role.value}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _handleApprove(context, user),
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Approve'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _handleReject(context, user),
                                      icon: const Icon(Icons.close, size: 18),
                                      label: const Text('Reject'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildRejectedUsersTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (userProvider.error != null) {
          return ErrorDisplayWidget(
            message: userProvider.error!,
            onRetry: () {
              userProvider.clearError();
              userProvider.loadRejectedUsers();
            },
          );
        }

        final rejectedUsers = userProvider.rejectedUsers;

        if (rejectedUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No rejected users',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            userProvider.loadRejectedUsers();
          },
          child: Responsive.isMobile(context)
              ? ListView.builder(
                  itemCount: rejectedUsers.length,
                  padding: Responsive.getHorizontalPadding(context),
                  itemBuilder: (context, index) {
                    final user = rejectedUsers[index];
                    return Card(
                      margin: EdgeInsets.only(
                        bottom: Responsive.getSpacing(context,
                            mobile: 8, tablet: 12, desktop: 16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: CircleAvatar(
                                child: Text(user.username[0].toUpperCase()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // User info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    user.username,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Role: ${user.role.value}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            // Trailing button
                            Flexible(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleApprove(context, user),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : ResponsiveLayout(
                  child: ResponsiveGrid(
                    mobileColumns: 1,
                    tabletColumns: 2,
                    desktopColumns: 3,
                    spacing: Responsive.getSpacing(context,
                        mobile: 12, tablet: 16, desktop: 20),
                    runSpacing: Responsive.getSpacing(context,
                        mobile: 12, tablet: 16, desktop: 20),
                    children: rejectedUsers.map((user) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: CircleAvatar(
                                  child: Text(user.username[0].toUpperCase()),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // User info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      user.username,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.email,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Role: ${user.role.value}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              // Trailing button
                              Flexible(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _handleApprove(context, user),
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text('Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _handleApprove(BuildContext context, User user) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.approveUser(user.id);

    if (context.mounted) {
      if (success) {
        showSuccessSnackBar(context, 'User approved successfully');
        // Reload lists
        userProvider.loadPendingUsers();
        userProvider.loadRejectedUsers();
        userProvider.loadAllUsers();
      } else {
        showErrorSnackBar(
            context, userProvider.error ?? 'Failed to approve user');
      }
    }
  }

  Future<void> _handleReject(BuildContext context, User user) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.rejectUser(user.id);

    if (context.mounted) {
      if (success) {
        showSuccessSnackBar(context, 'User rejected');
        // Reload lists
        userProvider.loadPendingUsers();
        userProvider.loadRejectedUsers();
        userProvider.loadAllUsers();
      } else {
        showErrorSnackBar(
            context, userProvider.error ?? 'Failed to reject user');
      }
    }
  }

  void _showRestrictDialog(BuildContext context, User user) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restrict User'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Enter reason for restriction',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _handleRestrict(context, user, reasonController.text);
              },
              child: const Text('Restrict'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text(
              'Are you sure you want to delete user "${user.username}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _handleDelete(context, user);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDelete(BuildContext context, User user) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.deleteUser(user.id);

    if (context.mounted) {
      if (success) {
        showSuccessSnackBar(context, 'User deleted successfully');
      } else {
        showErrorSnackBar(
            context, userProvider.error ?? 'Failed to delete user');
      }
    }
  }

  Future<void> _handleRestrict(
      BuildContext context, User user, String reason) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.restrictUser(user.id, reason);

    if (context.mounted) {
      if (success) {
        showSuccessSnackBar(context, 'User restricted successfully');
      } else {
        showErrorSnackBar(
            context, userProvider.error ?? 'Failed to restrict user');
      }
    }
  }

  Future<void> _handleUnrestrict(BuildContext context, User user) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.unrestrictUser(user.id);

    if (context.mounted) {
      if (success) {
        showSuccessSnackBar(context, 'User unrestricted successfully');
      } else {
        showErrorSnackBar(
            context, userProvider.error ?? 'Failed to unrestrict user');
      }
    }
  }

  void _showUserDetails(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user.username),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${user.email}'),
              Text('Role: ${user.role.value}'),
              Text('Restricted: ${user.restricted ? "Yes" : "No"}'),
              if (user.restricted && user.restrictionReason != null)
                Text('Reason: ${user.restrictionReason}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
