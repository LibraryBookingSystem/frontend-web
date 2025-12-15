import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resource_provider.dart';
import '../../providers/realtime_provider.dart';
import '../../widgets/resources/resource_card.dart';
import '../../widgets/resources/resource_filter_bar.dart';
import '../../widgets/common/loading_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_widget.dart';
import '../../constants/route_names.dart';
import '../../core/utils/responsive.dart';

/// Browse resources screen for students
class BrowseResourcesScreen extends StatefulWidget {
  const BrowseResourcesScreen({super.key});

  @override
  State<BrowseResourcesScreen> createState() => _BrowseResourcesScreenState();
}

class _BrowseResourcesScreenState extends State<BrowseResourcesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResources();
      _connectRealtime();
    });
  }

  void _loadResources() {
    final resourceProvider =
        Provider.of<ResourceProvider>(context, listen: false);
    final realtimeProvider =
        Provider.of<RealtimeProvider>(context, listen: false);
    
    // Set real-time availability map before loading so it syncs
    resourceProvider.setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);
    resourceProvider.loadResources();
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
        resourceProvider.setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);
        
        if (resourceProvider.allResources.isNotEmpty) {
          final resourceIds = resourceProvider.allResources.map((r) => r.id).toList();
          realtimeProvider.subscribeToResources(resourceIds);
          
          // Sync initial state with real-time availability map
          if (realtimeProvider.availabilityMap.isNotEmpty) {
            realtimeProvider.availabilityMap.forEach((resourceId, statusString) {
              resourceProvider.syncResourceWithRealtime(resourceId, statusString);
            });
            // Force sync all resources
            resourceProvider.syncAllResourcesWithRealtime();
          }
        } else {
          // Resources not loaded yet, wait a bit and retry
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && resourceProvider.allResources.isNotEmpty) {
              final resourceIds = resourceProvider.allResources.map((r) => r.id).toList();
              realtimeProvider.subscribeToResources(resourceIds);
              
              if (realtimeProvider.availabilityMap.isNotEmpty) {
                resourceProvider.setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);
                realtimeProvider.availabilityMap.forEach((resourceId, statusString) {
                  resourceProvider.syncResourceWithRealtime(resourceId, statusString);
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
    
    debugPrint('BrowseResources: Real-time update received, availability map size: ${realtimeProvider.availabilityMap.length}');
    
    // Update the availability map reference FIRST
    resourceProvider.setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);
    
    // Then sync each resource individually
    int updateCount = 0;
    realtimeProvider.availabilityMap.forEach((resourceId, statusString) {
      final matchingResources = resourceProvider.allResources.where((r) => r.id == resourceId).toList();
      if (matchingResources.isNotEmpty) {
        resourceProvider.syncResourceWithRealtime(resourceId, statusString);
        updateCount++;
        debugPrint('BrowseResources: Synced resource $resourceId to $statusString (was ${matchingResources.first.status.value})');
      }
    });
    
    debugPrint('BrowseResources: Synced $updateCount resources, total resources: ${resourceProvider.allResources.length}');
    
    // Force sync all resources to ensure consistency
    resourceProvider.syncAllResourcesWithRealtime();
  }
  
  @override
  void dispose() {
    try {
      final realtimeProvider =
          Provider.of<RealtimeProvider>(context, listen: false);
      realtimeProvider.removeListener(_handleRealtimeUpdate);
    } catch (e) {
      // Provider may not be available during dispose
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Resources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.floorPlan);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Consumer<ResourceProvider>(
            builder: (context, resourceProvider, _) {
              // Extract unique floors from all resources (unfiltered) to show all available options
              final availableFloors = resourceProvider.allResources
                  .map((r) => r.floor)
                  .toSet()
                  .toList()
                ..sort();
              
              return ResourceFilterBar(
                selectedType: resourceProvider.filterType,
                selectedFloor: resourceProvider.filterFloor,
                selectedStatus: resourceProvider.filterStatus,
                searchQuery: resourceProvider.searchQuery,
                availableFloors: availableFloors.isNotEmpty ? availableFloors : null,
                onTypeChanged: (type) {
                  resourceProvider.filterResources(type: type);
                },
                onFloorChanged: (floor) {
                  resourceProvider.filterResources(floor: floor);
                },
                onStatusChanged: (status) {
                  resourceProvider.filterResources(status: status);
                },
                onSearchChanged: (query) {
                  resourceProvider.searchResources(query);
                },
                onClearFilters: () {
                  resourceProvider.clearFilters();
                  resourceProvider.loadResources();
                },
              );
            },
          ),
          // Resource list
          Expanded(
            child: Consumer<ResourceProvider>(
              builder: (context, resourceProvider, _) {
                if (resourceProvider.isLoading) {
                  return Responsive.isMobile(context)
                      ? ListView.builder(
                          padding: Responsive.getPadding(context),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return LoadingCard(
                              height: 120,
                              margin: EdgeInsets.only(
                                bottom: Responsive.getSpacing(context,
                                    mobile: 12, tablet: 16, desktop: 16),
                              ),
                            );
                          },
                        )
                      : SingleChildScrollView(
                          padding: Responsive.getPadding(context),
                          child: ResponsiveLayout(
                            child: ResponsiveGrid(
                              mobileColumns: 1,
                              tabletColumns: 2,
                              desktopColumns: 3,
                              spacing: Responsive.getSpacing(context,
                                  mobile: 12, tablet: 16, desktop: 20),
                              runSpacing: Responsive.getSpacing(context,
                                  mobile: 12, tablet: 16, desktop: 20),
                              children: List.generate(
                                6,
                                (index) => const LoadingGridItem(),
                              ),
                            ),
                          ),
                        );
                }

                if (resourceProvider.error != null) {
                  return ErrorDisplayWidget(
                    message: resourceProvider.error!,
                    onRetry: () {
                      resourceProvider.clearError();
                      _loadResources();
                    },
                  );
                }

                final resources = resourceProvider.resources;

                if (resources.isEmpty) {
                  return EmptyResourcesState(
                    onRefresh: _loadResources,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadResources();
                  },
                  child: Responsive.isMobile(context)
                      ? ListView.builder(
                          padding: Responsive.getPadding(context),
                          itemCount: resources.length,
                          itemBuilder: (context, index) {
                            final resource = resources[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: Responsive.getSpacing(context, mobile: 12, tablet: 16, desktop: 16),
                              ),
                              child: ResourceCard(
                                resource: resource,
                                index: index,
                                onTap: () {
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
                                    return;
                                  }
                                  Navigator.pushNamed(
                                    context,
                                    RouteNames.createBooking,
                                    arguments: resource.id,
                                  );
                                },
                              ),
                            );
                          },
                        )
                      : SingleChildScrollView(
                          padding: Responsive.getPadding(context),
                          child: ResponsiveLayout(
                            child: ResponsiveGrid(
                              mobileColumns: 1,
                              tabletColumns: 2,
                              desktopColumns: 3,
                              spacing: Responsive.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
                              runSpacing: Responsive.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
                              children: resources.asMap().entries.map((entry) {
                                final index = entry.key;
                                final resource = entry.value;
                                return ResourceCard(
                                  resource: resource,
                                  index: index,
                                  onTap: () {
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
                                      return;
                                    }
                                    Navigator.pushNamed(
                                      context,
                                      RouteNames.createBooking,
                                      arguments: resource.id,
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteNames.createBooking);
        },
        tooltip: 'Create Booking',
        child: const Icon(Icons.add),
      ),
    );
  }
}
