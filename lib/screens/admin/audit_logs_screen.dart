import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audit_log_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/audit_log.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../theme/app_theme.dart';
import '../../widgets/common/theme_switcher.dart';

/// Audit logs screen for admins
class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final ScrollController _scrollController = ScrollController();
  DateTimeRange? _dateRange;
  String? _selectedUser;
  String? _selectedActionType;
  String? _selectedResourceType;

  @override
  void initState() {
    super.initState();
    // Default to last 7 days
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));
    _dateRange = DateTimeRange(start: startDate, end: endDate);

    // Load audit logs on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = Provider.of<AuditLogProvider>(context, listen: false);
      if (!provider.isLoading &&
          provider.currentPage != null &&
          !provider.currentPage!.last) {
        provider.loadMore();
      }
    }
  }

  void _applyFilters() {
    final provider = Provider.of<AuditLogProvider>(context, listen: false);
    provider.setFilters(
      userId: _selectedUser != null ? int.tryParse(_selectedUser!) : null,
      actionType: _selectedActionType,
      resourceType: _selectedResourceType,
      startTime: _dateRange?.start,
      endTime: _dateRange?.end,
    );
    provider.loadAuditLogs();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          const ThemeSwitcherIcon(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              Provider.of<AuditLogProvider>(context, listen: false).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedUser = null;
                            _selectedActionType = null;
                            _selectedResourceType = null;
                            final endDate = DateTime.now();
                            final startDate =
                                endDate.subtract(const Duration(days: 7));
                            _dateRange =
                                DateTimeRange(start: startDate, end: endDate);
                          });
                          Provider.of<AuditLogProvider>(context, listen: false)
                              .clearFilters();
                          _applyFilters();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Date range
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: const Text('Date Range'),
                    subtitle: Text(
                      _dateRange != null
                          ? '${date_utils.AppDateUtils.formatDate(_dateRange!.start)} - ${date_utils.AppDateUtils.formatDate(_dateRange!.end)}'
                          : 'Select date range',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _selectDateRange(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Action type filter
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Action Type',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedActionType,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Actions')),
                      DropdownMenuItem(value: 'CREATE', child: Text('Create')),
                      DropdownMenuItem(value: 'UPDATE', child: Text('Update')),
                      DropdownMenuItem(value: 'DELETE', child: Text('Delete')),
                      DropdownMenuItem(value: 'LOGIN', child: Text('Login')),
                      DropdownMenuItem(value: 'LOGOUT', child: Text('Logout')),
                      DropdownMenuItem(value: 'VIEW', child: Text('View')),
                      DropdownMenuItem(
                          value: 'CHECK_IN', child: Text('Check In')),
                      DropdownMenuItem(value: 'CANCEL', child: Text('Cancel')),
                      DropdownMenuItem(
                          value: 'APPROVE', child: Text('Approve')),
                      DropdownMenuItem(
                          value: 'MANAGE_USER', child: Text('Manage User')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedActionType = value;
                      });
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 8),
                  // Resource type filter
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Resource Type',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedResourceType,
                    items: const [
                      DropdownMenuItem(
                          value: null, child: Text('All Resources')),
                      DropdownMenuItem(
                          value: 'RESOURCE', child: Text('Resource')),
                      DropdownMenuItem(
                          value: 'BOOKING', child: Text('Booking')),
                      DropdownMenuItem(value: 'POLICY', child: Text('Policy')),
                      DropdownMenuItem(value: 'USER', child: Text('User')),
                      DropdownMenuItem(
                          value: 'NOTIFICATION', child: Text('Notification')),
                      DropdownMenuItem(
                          value: 'AUTH', child: Text('Authentication')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedResourceType = value;
                      });
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 8),
                  // Apply button
                  ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.search),
                    label: const Text('Apply Filters'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Audit logs list
          Expanded(
            child: Consumer<AuditLogProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.auditLogs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.auditLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading audit logs',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.auditLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No audit logs found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: provider.auditLogs.length +
                        (provider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.auditLogs.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final log = provider.auditLogs[index];
                      return _buildAuditLogItem(context, log);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogItem(BuildContext context, AuditLog log) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionColor = _getActionColor(log.actionType);
    final successColor =
        log.success ? AppTheme.successColor : AppTheme.errorColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _showLogDetails(context, log),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: actionColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.actionTypeDisplay,
                      style: TextStyle(
                        color: actionColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.resourceTypeDisplay,
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    log.success ? Icons.check_circle : Icons.error,
                    color: successColor,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (log.description != null) ...[
                Text(
                  log.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (log.username != null) ...[
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      log.username!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    date_utils.AppDateUtils.formatDateTime(log.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              if (log.errorMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 16, color: AppTheme.errorColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          log.errorMessage!,
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getActionColor(String actionType) {
    switch (actionType) {
      case 'CREATE':
        return AppTheme.successColor;
      case 'UPDATE':
        return AppTheme.infoColor;
      case 'DELETE':
        return AppTheme.errorColor;
      case 'LOGIN':
      case 'LOGOUT':
        return AppTheme.purpleColor;
      case 'VIEW':
        return Colors.blue;
      case 'CHECK_IN':
        return AppTheme.successColor;
      case 'CANCEL':
        return AppTheme.warningColor;
      case 'APPROVE':
        return AppTheme.successColor;
      case 'MANAGE_USER':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showLogDetails(BuildContext context, AuditLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Audit Log Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Action Type', log.actionTypeDisplay),
            if (log.resourceType != null)
              _buildDetailRow(
                  context, 'Resource Type', log.resourceTypeDisplay),
            if (log.resourceName != null)
              _buildDetailRow(context, 'Resource Name', log.resourceName!),
            if (log.resourceId != null)
              _buildDetailRow(
                  context, 'Resource ID', log.resourceId.toString()),
            if (log.username != null)
              _buildDetailRow(context, 'User', log.username!),
            if (log.userRole != null)
              _buildDetailRow(context, 'Role', log.userRole!),
            if (log.ipAddress != null)
              _buildDetailRow(context, 'IP Address', log.ipAddress!),
            _buildDetailRow(
                context, 'Status', log.success ? 'Success' : 'Failed'),
            _buildDetailRow(context, 'Timestamp',
                date_utils.AppDateUtils.formatDateTime(log.timestamp)),
            if (log.description != null) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(log.description!),
            ],
            if (log.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error Message',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.errorColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(log.errorMessage!),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
