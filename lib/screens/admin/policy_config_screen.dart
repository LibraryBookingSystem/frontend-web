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

class _PolicyConfigScreenState extends State<PolicyConfigScreen> with ErrorHandlingMixin {
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
          title: Text(_editingPolicy == null ? 'Create Policy' : 'Edit Policy'),
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
          
          final policies = _showActiveOnly ? policyProvider.activePolicies : policyProvider.policies;
          
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
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              _loadPolicies();
            },
            child: Responsive.isMobile(context)
                ? ListView.builder(
                    itemCount: policies.length,
                    padding: Responsive.getPadding(context),
                    itemBuilder: (context, index) {
                      final policy = policies[index];
                      return Card(
                        margin: EdgeInsets.only(
                          bottom: Responsive.getSpacing(context, size: SpacingSize.small),
                        ),
                        child: ListTile(
                          leading: Icon(
                            policy.active ? Icons.check_circle : Icons.cancel,
                            color: policy.active ? Colors.green : Colors.grey,
                          ),
                          title: Text(policy.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(policy.description ?? ''),
                              const SizedBox(height: 4),
                              Text(
                                '${policy.ruleType.value}: ${policy.ruleValue}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
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
                        ),
                      );
                    },
                  )
                : ResponsiveLayout(
                    child: ResponsiveGrid(
                      mobileColumns: 1,
                      tabletColumns: 2,
                      desktopColumns: 3,
                      spacing: Responsive.getSpacing(context, size: SpacingSize.medium),
                      runSpacing: Responsive.getSpacing(context, size: SpacingSize.medium),
                      children: policies.map((policy) {
                        return Card(
                          margin: EdgeInsets.only(
                            bottom: Responsive.getSpacing(context, size: SpacingSize.small),
                          ),
                          child: ListTile(
                            leading: Icon(
                              policy.active ? Icons.check_circle : Icons.cancel,
                              color: policy.active ? Colors.green : Colors.grey,
                            ),
                            title: Text(policy.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(policy.description ?? ''),
                                const SizedBox(height: 4),
                                Text(
                                  '${policy.ruleType.value}: ${policy.ruleValue}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
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
                          ),
                        );
                      }).toList(),
                    ),
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
  
  Future<void> _handleSubmit(Map<String, dynamic> request) async {
    final policyProvider = Provider.of<PolicyProvider>(context, listen: false);
    
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
                final policyProvider = Provider.of<PolicyProvider>(context, listen: false);
                final success = await policyProvider.deletePolicy(policy.id);
                if (context.mounted) {
                  if (success) {
                    showSuccessSnackBar(context, 'Policy deleted successfully');
                  } else {
                    showErrorSnackBar(context, policyProvider.error ?? 'Failed to delete policy');
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