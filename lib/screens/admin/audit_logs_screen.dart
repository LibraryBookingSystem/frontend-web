import 'package:flutter/material.dart';

/// Audit logs screen for admins
/// Note: This screen assumes audit logs API exists in the backend
class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});
  
  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  DateTimeRange? _dateRange;
  String? _selectedUser;
  String? _selectedActionType;
  
  @override
  void initState() {
    super.initState();
    // Default to last 7 days
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));
    _dateRange = DateTimeRange(start: startDate, end: endDate);
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
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
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
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date range
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: const Text('Date Range'),
                    subtitle: Text(
                      _dateRange != null
                          ? '${_dateRange!.start.toString().substring(0, 10)} - ${_dateRange!.end.toString().substring(0, 10)}'
                          : 'Select date range',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _selectDateRange(context),
                    ),
                  ),
                  // User filter (would be populated from API)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'User',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedUser,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Users')),
                      // Would be populated from API
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedUser = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
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
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedActionType = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Audit logs list (placeholder - would be populated from API)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Audit Logs',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Audit logs API endpoint not yet implemented',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

