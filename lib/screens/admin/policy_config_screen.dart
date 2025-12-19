import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/policy_provider.dart';
import '../../widgets/admin/policy_form.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../core/mixins/error_handling_mixin.dart';
import '../../models/policy.dart';
import '../../core/utils/responsive.dart';

/// Policy configuration screen for admins
class PolicyConfigScreen extends StatefulWidget {
  const PolicyConfigScreen({super.key});

  @override
  State<PolicyConfigScreen> createState() => _PolicyConfigScreenState();
}

class _PolicyConfigScreenState extends State<PolicyConfigScreen>
    with ErrorHandlingMixin {
  bool _showForm = false;
  Policy? _editingPolicy;
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPolicies();
    });
  }

  void _loadPolicies() {
    final policyProvider = Provider.of<PolicyProvider>(context, listen: false);
    policyProvider.loadPolicies(active: _showActiveOnly ? true : null);
  }

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return Scaffold(
        appBar: AppBar(
          title:
              Text(_editingPolicy == null ? 'Create Policy' : 'Edit Policy'),
        ),
        body: ResponsiveFormLayout(
          child: PolicyForm(
            initialPolicy: _editingPolicy,
            isLoading: false,
            onSubmit: (request) async {
              await _handleSubmit(request);
            },
            onCancel: () {
              setState(() {
                _showForm = false;
                _editingPolicy = null;
              });
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy Configuration'),
        actions: [
          Switch(
            value: _showActiveOnly,
            onChanged: (value) {
              setState(() {
                _showActiveOnly = value;
              });
              _loadPolicies();
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Active Only'),
          ),
        ],
      ),
      body: Consumer<PolicyProvider>(
        builder: (context, policyProvider, _) {
          if (policyProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (policyProvider.error != null) {
            return ErrorDisplayWidget(
              message: policyProvider.error!,
              onRetry: () {
                policyProvider.clearError();
                _loadPolicies();
              },
            );
          }

          final policies = _showActiveOnly
              ? policyProvider.activePolicies
              : policyProvider.policies;

          if (policies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.policy, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No policies found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Create a policy to set booking rules'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadPolicies();
            },
            child: ListView.builder(
              itemCount: policies.length,
              padding: Responsive.getPadding(context),
              itemBuilder: (context, index) {
                final policy = policies[index];
                return _buildPolicyCard(context, policy);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _editingPolicy = null;
            _showForm = true;
          });
        },
        tooltip: 'Add Policy',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPolicyCard(BuildContext context, Policy policy) {
    return Card(
      margin: EdgeInsets.only(
        bottom: Responsive.getSpacing(context, size: SpacingSize.small),
      ),
      child: ExpansionTile(
        leading: Icon(
          policy.isActive ? Icons.check_circle : Icons.cancel,
          color: policy.isActive ? Colors.green : Colors.grey,
        ),
        title: Text(
          policy.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          policy.isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            color: policy.isActive ? Colors.green : Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _editingPolicy = policy;
                  _showForm = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(context, policy);
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPolicyDetail(
                  Icons.timer,
                  'Max Duration',
                  policy.maxDurationMinutes != null
                      ? '${policy.maxDurationMinutes} minutes (${(policy.maxDurationMinutes! / 60).toStringAsFixed(1)} hours)'
                      : 'Not set',
                ),
                const SizedBox(height: 8),
                _buildPolicyDetail(
                  Icons.calendar_today,
                  'Max Advance Days',
                  policy.maxAdvanceDays != null
                      ? '${policy.maxAdvanceDays} days'
                      : 'Not set',
                ),
                const SizedBox(height: 8),
                _buildPolicyDetail(
                  Icons.bookmark_border,
                  'Max Concurrent Bookings',
                  policy.maxConcurrentBookings != null
                      ? '${policy.maxConcurrentBookings} bookings'
                      : 'Not set',
                ),
                const SizedBox(height: 8),
                _buildPolicyDetail(
                  Icons.access_time,
                  'Grace Period',
                  policy.gracePeriodMinutes != null
                      ? '${policy.gracePeriodMinutes} minutes'
                      : 'Not set',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit(Map<String, dynamic> request) async {
    final policyProvider =
        Provider.of<PolicyProvider>(context, listen: false);

    final success = _editingPolicy == null
        ? await policyProvider.createPolicy(request)
        : await policyProvider.updatePolicy(_editingPolicy!.id, request);

    if (mounted) {
      if (success) {
        showSuccessSnackBar(
          context,
          _editingPolicy == null
              ? 'Policy created successfully'
              : 'Policy updated successfully',
        );
        setState(() {
          _showForm = false;
          _editingPolicy = null;
        });
        _loadPolicies();
      } else {
        showErrorSnackBar(
          context,
          policyProvider.error ?? 'Failed to save policy',
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, Policy policy) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Policy'),
          content: Text('Are you sure you want to delete ${policy.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final policyProvider =
                    Provider.of<PolicyProvider>(context, listen: false);
                final success = await policyProvider.deletePolicy(policy.id);
                if (context.mounted) {
                  if (success) {
                    showSuccessSnackBar(context, 'Policy deleted successfully');
                  } else {
                    showErrorSnackBar(context,
                        policyProvider.error ?? 'Failed to delete policy');
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
