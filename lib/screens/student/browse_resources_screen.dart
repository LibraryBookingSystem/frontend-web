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
    resourceProvider.loadResources();
  }

  void _connectRealtime() {
    try {
      final realtimeProvider =
          Provider.of<RealtimeProvider>(context, listen: false);
      realtimeProvider.connect().catchError((error) {
        // Silently handle WebSocket connection errors - polling fallback will be used
      });
    } catch (e) {
      // Silently handle any errors - WebSocket may not be available
    }
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
