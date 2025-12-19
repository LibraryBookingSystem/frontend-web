import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resource_provider.dart';
import '../../providers/realtime_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/policy_provider.dart';
import '../../widgets/resources/floor_plan_widget.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../constants/route_names.dart';
import '../../models/resource.dart';
import '../../models/policy.dart';
import '../../widgets/common/theme_switcher.dart';

/// Floor plan screen with interactive SVG map
class FloorPlanScreen extends StatefulWidget {
  const FloorPlanScreen({super.key});

  @override
  State<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends State<FloorPlanScreen> {
  int? _selectedFloor;

  @override
  void initState() {
    super.initState();
    // Default to Floor 1 when page loads
    _selectedFloor = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResources();
      _connectRealtime();
      // Apply initial floor filter
      final resourceProvider =
          Provider.of<ResourceProvider>(context, listen: false);
      resourceProvider.filterResources(floor: _selectedFloor);
    });
  }

  void _loadResources() async {
    final resourceProvider =
        Provider.of<ResourceProvider>(context, listen: false);
    final realtimeProvider =
        Provider.of<RealtimeProvider>(context, listen: false);
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final policyProvider = Provider.of<PolicyProvider>(context, listen: false);

    // Load active policies
    policyProvider.loadActivePolicies();

    // Set real-time availability map before loading so it syncs
    resourceProvider
        .setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);
    await resourceProvider.loadResources();

    // Fetch currently booked resources and mark them as unavailable
    try {
      final bookedResourceIds = await bookingProvider.getBookedResourceIds();
      debugPrint(
          'FloorPlan: Fetched ${bookedResourceIds.length} booked resource IDs');

      bool anyUpdated = false;
      for (final resourceId in bookedResourceIds) {
        resourceProvider.updateResourceAvailability(
            resourceId, ResourceStatus.unavailable);
        resourceProvider.syncResourceWithRealtime(resourceId, 'unavailable');
        anyUpdated = true;
      }

      // Force a final notification to ensure UI updates after batch update
      if (anyUpdated) {
        resourceProvider.forceNotifyListeners();
      }
    } catch (e) {
      debugPrint('FloorPlan: Failed to fetch booked resources: $e');
    }
  }

  void _connectRealtime() {
    try {
      final realtimeProvider =
          Provider.of<RealtimeProvider>(context, listen: false);
      final resourceProvider =
          Provider.of<ResourceProvider>(context, listen: false);

      // Connect to WebSocket
      realtimeProvider.connect().catchError((error) {
        // Silently handle WebSocket connection errors - polling fallback will be used
      });

      // Listen to real-time updates and update ResourceProvider
      realtimeProvider.addListener(_handleRealtimeUpdate);

      // Subscribe to all resources when they're loaded
      // Also sync initial state with real-time availability
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Set availability map reference first
        resourceProvider
            .setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);

        if (resourceProvider.allResources.isNotEmpty) {
          final resourceIds =
              resourceProvider.allResources.map((r) => r.id).toList();
          realtimeProvider.subscribeToResources(resourceIds);

          // Sync initial state with real-time availability map
          if (realtimeProvider.availabilityMap.isNotEmpty) {
            realtimeProvider.availabilityMap
                .forEach((resourceId, statusString) {
              resourceProvider.syncResourceWithRealtime(
                  resourceId, statusString);
            });
            // Force sync all resources
            resourceProvider.syncAllResourcesWithRealtime();
          }
        } else {
          // Resources not loaded yet, wait a bit and retry
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && resourceProvider.allResources.isNotEmpty) {
              final resourceIds =
                  resourceProvider.allResources.map((r) => r.id).toList();
              realtimeProvider.subscribeToResources(resourceIds);

              if (realtimeProvider.availabilityMap.isNotEmpty) {
                resourceProvider.setRealtimeAvailabilityMap(
                    realtimeProvider.availabilityMap);
                realtimeProvider.availabilityMap
                    .forEach((resourceId, statusString) {
                  resourceProvider.syncResourceWithRealtime(
                      resourceId, statusString);
                });
                resourceProvider.syncAllResourcesWithRealtime();
              }
            }
          });
        }
      });
    } catch (e) {
      // Silently handle any errors - WebSocket may not be available
    }
  }

  void _handleRealtimeUpdate() {
    if (!mounted) return;

    final realtimeProvider =
        Provider.of<RealtimeProvider>(context, listen: false);
    final resourceProvider =
        Provider.of<ResourceProvider>(context, listen: false);

    // Update the availability map reference FIRST
    resourceProvider
        .setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);

    // Then sync each resource individually
    realtimeProvider.availabilityMap.forEach((resourceId, statusString) {
      resourceProvider.syncResourceWithRealtime(resourceId, statusString);
    });

    // Force sync all resources to ensure consistency
    resourceProvider.syncAllResourcesWithRealtime();
  }

  @override
  void dispose() {
    try {
      final realtimeProvider =
          Provider.of<RealtimeProvider>(context, listen: false);
      realtimeProvider.removeListener(_handleRealtimeUpdate);
      // Clear callbacks
      realtimeProvider.onResourceCreated = null;
      realtimeProvider.onResourceDeleted = null;
      realtimeProvider.onPolicyCreated = null;
      realtimeProvider.onPolicyUpdated = null;
      realtimeProvider.onPolicyDeleted = null;
    } catch (e) {
      // Provider may not be available during dispose
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ResourceProvider>(
          builder: (context, resourceProvider, _) {
            // Get available floors from resources
            final availableFloors = resourceProvider.allResources
                .map((r) => r.floor)
                .toSet()
                .toList()
              ..sort();

            // If no floors available yet, show default title
            if (availableFloors.isEmpty) {
              return const Text('Floor Plan');
            }

            // Show current floor selection in title
            final floorText = _selectedFloor != null
                ? 'Floor Plan - Floor $_selectedFloor'
                : 'Floor Plan - All Floors';
            return Text(floorText);
          },
        ),
        actions: [
          const ThemeSwitcherIcon(),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Resources',
            onPressed: _loadResources,
          ),
          // Floor selector with dynamic floors
          Consumer<ResourceProvider>(
            builder: (context, resourceProvider, _) {
              // Get available floors from resources
              final availableFloors = resourceProvider.allResources
                  .map((r) => r.floor)
                  .toSet()
                  .toList()
                ..sort();

              // If no floors available, don't show menu
              if (availableFloors.isEmpty) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<int?>(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.layers),
                    if (_selectedFloor != null) ...[
                      const SizedBox(width: 4),
                      Chip(
                        label: Text('Floor $_selectedFloor'),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
                onSelected: (floor) {
                  setState(() {
                    _selectedFloor = floor;
                  });
                  final resourceProvider =
                      Provider.of<ResourceProvider>(context, listen: false);
                  resourceProvider.filterResources(floor: floor);
                },
                itemBuilder: (context) => [
                  // All Floors option
                  PopupMenuItem<int?>(
                    value: null,
                    child: Row(
                      children: [
                        Icon(
                          _selectedFloor == null ? Icons.check : null,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('All Floors'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  // Individual floor options
                  ...availableFloors.map((floor) {
                    return PopupMenuItem<int?>(
                      value: floor,
                      child: Row(
                        children: [
                          Icon(
                            _selectedFloor == floor ? Icons.check : null,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('Floor $floor'),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ResourceProvider>(
        builder: (context, resourceProvider, _) {
          if (resourceProvider.isLoading) {
            return const LoadingIndicator();
          }

          final resources = _selectedFloor != null
              ? resourceProvider.resources
                  .where((r) => r.floor == _selectedFloor)
                  .toList()
              : resourceProvider.resources;

          return Column(
            children: [
              // Policy display widget
              Consumer<PolicyProvider>(
                builder: (context, policyProvider, _) {
                  final activePolicies = policyProvider.activePolicies;
                  if (activePolicies.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: ExpansionTile(
                      leading: const Icon(Icons.policy, color: Colors.blue),
                      title: const Text(
                        'Active Booking Policies',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text('${activePolicies.length} active policy(ies)'),
                      children: activePolicies.map((policy) {
                        return _buildPolicyItem(context, policy);
                      }).toList(),
                    ),
                  );
                },
              ),
              // Floor plan widget
              Expanded(
                child: FloorPlanWidget(
                  resources: resources,
                  selectedFloor: _selectedFloor,
                  onResourceTap: (resource) {
                    if (!resource.isAvailable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${resource.name} is ${resource.status.value.toLowerCase()} and cannot be booked',
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                    _showResourceDetails(context, resource);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResourceDetails(BuildContext context, resource) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text('Type: ${resource.type.value}'),
                Text('Floor: ${resource.floor}'),
                Text('Capacity: ${resource.capacity}'),
                Text('Status: ${resource.status.value}'),
                if (!resource.isAvailable)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'This resource is not available for booking',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                    ElevatedButton(
                      onPressed: resource.isAvailable
                          ? () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                RouteNames.createBooking,
                                arguments: resource.id,
                              );
                            }
                          : null,
                      child: Text(
                          resource.isAvailable ? 'Book Now' : 'Not Available'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPolicyItem(BuildContext context, Policy policy) {
    final List<String> policyDetails = [];

    if (policy.maxDurationMinutes != null) {
      final hours = (policy.maxDurationMinutes! / 60).toStringAsFixed(1);
      policyDetails.add('Max Duration: $hours hours');
    }
    if (policy.maxAdvanceDays != null) {
      policyDetails.add('Max Advance: ${policy.maxAdvanceDays} days');
    }
    if (policy.maxConcurrentBookings != null) {
      policyDetails.add('Max Concurrent: ${policy.maxConcurrentBookings}');
    }
    if (policy.gracePeriodMinutes != null) {
      policyDetails.add('Grace Period: ${policy.gracePeriodMinutes} minutes');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            policy.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (policyDetails.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...policyDetails.map((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          detail,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
