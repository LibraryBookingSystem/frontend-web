import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resource_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/admin/resource_form.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../core/mixins/error_handling_mixin.dart';
import '../../models/resource.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/enhanced_section.dart';
import '../../core/animations/animation_utils.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/theme_switcher.dart';

/// Resource management screen for admins
class ResourceManagementScreen extends StatefulWidget {
  const ResourceManagementScreen({super.key});

  @override
  State<ResourceManagementScreen> createState() =>
      _ResourceManagementScreenState();
}

class _ResourceManagementScreenState extends State<ResourceManagementScreen>
    with ErrorHandlingMixin {
  bool _showForm = false;
  Resource? _editingResource;
  Set<int> _bookedResourceIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadResources(),
      _loadBookedResources(),
    ]);
  }

  Future<void> _loadResources() async {
    final resourceProvider =
        Provider.of<ResourceProvider>(context, listen: false);
    await resourceProvider.loadResources();
  }

  Future<void> _loadBookedResources() async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final bookedIds = await bookingProvider.getBookedResourceIds();
    if (mounted) {
      setState(() {
        _bookedResourceIds = bookedIds.toSet();
      });
    }
  }

  bool _isResourceBooked(int resourceId) {
    return _bookedResourceIds.contains(resourceId);
  }

  String _getAvailabilityStatus(Resource resource) {
    if (_isResourceBooked(resource.id)) {
      return 'Booked';
    }
    return resource.status.value;
  }

  Color _getAvailabilityColor(Resource resource) {
    if (_isResourceBooked(resource.id)) {
      return Colors.red;
    }
    switch (resource.status) {
      case ResourceStatus.available:
        return Colors.green;
      case ResourceStatus.unavailable:
        return Colors.red;
      case ResourceStatus.maintenance:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              _editingResource == null ? 'Create Resource' : 'Edit Resource'),
          actions: [
            ThemeSwitcherIcon(),
          ],
        ),
        body: ResponsiveFormLayout(
          child: ResourceForm(
            initialResource: _editingResource,
            isLoading: false,
            onSubmit: (request) async {
              await _handleSubmit(request);
            },
            onCancel: () {
              setState(() {
                _showForm = false;
                _editingResource = null;
              });
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Management'),
        actions: [
          ThemeSwitcherIcon(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<ResourceProvider>(
        builder: (context, resourceProvider, _) {
          if (resourceProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (resourceProvider.error != null) {
            return ErrorDisplayWidget(
              message: resourceProvider.error!,
              onRetry: () {
                resourceProvider.clearError();
                _loadData();
              },
            );
          }

          final resources = resourceProvider.resources;

          if (resources.isEmpty) {
            return EmptyResourcesState(
              onRefresh: _loadData,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: Responsive.isMobile(context)
                ? ListView.builder(
                    itemCount: resources.length,
                    padding: Responsive.getPadding(context),
                    itemBuilder: (context, index) {
                      final resource = resources[index];
                      return AnimationUtils.staggeredFadeIn(
                        index: index,
                        child: _buildResourceCard(resource),
                      );
                    },
                  )
                : SingleChildScrollView(
                    child: ResponsiveLayout(
                      child: ResponsiveGrid(
                        mobileColumns: 1,
                        tabletColumns: 2,
                        desktopColumns: 3,
                        spacing: Responsive.getSpacing(context,
                            mobile: 12, tablet: 16, desktop: 20),
                        runSpacing: Responsive.getSpacing(context,
                            mobile: 12, tablet: 16, desktop: 20),
                        children: resources.asMap().entries.map((entry) {
                          final index = entry.key;
                          final resource = entry.value;
                          return AnimationUtils.staggeredFadeIn(
                            index: index,
                            child: _buildResourceCard(resource),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _editingResource = null;
            _showForm = true;
          });
        },
        tooltip: 'Add Resource',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildResourceCard(Resource resource) {
    final isBooked = _isResourceBooked(resource.id);
    final availabilityStatus = _getAvailabilityStatus(resource);
    final availabilityColor = _getAvailabilityColor(resource);

    return EnhancedCard(
      color: _getResourceColor(resource.type),
      margin: EdgeInsets.only(
        bottom:
            Responsive.getSpacing(context, mobile: 8, tablet: 12, desktop: 16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getResourceColor(resource.type).withValues(alpha: 0.3),
                _getResourceColor(resource.type).withValues(alpha: 0.2),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getResourceIcon(resource.type),
            color: _getResourceColor(resource.type),
          ),
        ),
        title: Text(
          resource.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${resource.type.value} - Floor ${resource.floor}',
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: availabilityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  availabilityStatus,
                  style: TextStyle(
                    color: availabilityColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                if (isBooked) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.event_busy, size: 14, color: Colors.red),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.infoColor),
              onPressed: () {
                setState(() {
                  _editingResource = resource;
                  _showForm = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.errorColor),
              onPressed: () {
                _showDeleteDialog(context, resource);
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getResourceIcon(ResourceType type) {
    switch (type) {
      case ResourceType.studyRoom:
      case ResourceType.groupRoom:
        return Icons.meeting_room;
      case ResourceType.computerStation:
        return Icons.computer;
      case ResourceType.seat:
        return Icons.chair;
    }
  }

  Color _getResourceColor(ResourceType type) {
    switch (type) {
      case ResourceType.studyRoom:
      case ResourceType.groupRoom:
        return AppTheme.infoColor;
      case ResourceType.computerStation:
        return AppTheme.warningColor;
      case ResourceType.seat:
        return AppTheme.successColor;
    }
  }

  Future<void> _handleSubmit(Map<String, dynamic> request) async {
    final resourceProvider =
        Provider.of<ResourceProvider>(context, listen: false);

    final success = _editingResource == null
        ? await resourceProvider.createResource(request)
        : await resourceProvider.updateResource(_editingResource!.id, request);

    if (mounted) {
      if (success) {
        showSuccessSnackBar(
          context,
          _editingResource == null
              ? 'Resource created successfully'
              : 'Resource updated successfully',
        );
        setState(() {
          _showForm = false;
          _editingResource = null;
        });
        _loadData();
      } else {
        showErrorSnackBar(
          context,
          resourceProvider.error ?? 'Failed to save resource',
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, Resource resource) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Resource'),
          content: Text('Are you sure you want to delete ${resource.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final resourceProvider =
                    Provider.of<ResourceProvider>(context, listen: false);
                final success =
                    await resourceProvider.deleteResource(resource.id);
                if (context.mounted) {
                  if (success) {
                    showSuccessSnackBar(
                        context, 'Resource deleted successfully');
                  } else {
                    showErrorSnackBar(context,
                        resourceProvider.error ?? 'Failed to delete resource');
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
