import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/resource_provider.dart';
import '../../providers/realtime_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/theme_switcher.dart';

/// Occupancy overview screen for staff
class OccupancyOverviewScreen extends StatefulWidget {
  const OccupancyOverviewScreen({super.key});

  @override
  State<OccupancyOverviewScreen> createState() =>
      _OccupancyOverviewScreenState();
}

class _OccupancyOverviewScreenState extends State<OccupancyOverviewScreen> {
  int? _selectedFloor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _connectRealtime();
    });
  }

  void _loadData() {
    final resourceProvider =
        Provider.of<ResourceProvider>(context, listen: false);
    final realtimeProvider =
        Provider.of<RealtimeProvider>(context, listen: false);

    // Set real-time availability map before loading so it syncs
    resourceProvider
        .setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);
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
            resourceProvider.syncAllResourcesWithRealtime();
          }
        } else {
          // Resources not loaded yet, wait and retry
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && resourceProvider.allResources.isNotEmpty) {
              resourceProvider
                  .setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);
              final resourceIds =
                  resourceProvider.allResources.map((r) => r.id).toList();
              realtimeProvider.subscribeToResources(resourceIds);

              if (realtimeProvider.availabilityMap.isNotEmpty) {
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

    // Update the availability map reference
    resourceProvider
        .setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);

    // Update ResourceProvider when availability changes
    realtimeProvider.availabilityMap.forEach((resourceId, statusString) {
      resourceProvider.syncResourceWithRealtime(resourceId, statusString);
    });
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
        title: const Text('Occupancy Overview'),
        actions: [
          if (_selectedFloor != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Chip(
                label: Text(
                  'Floor $_selectedFloor',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                visualDensity: VisualDensity.compact,
                deleteIcon: Icon(
                  Icons.close,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                onDeleted: () {
                  setState(() {
                    _selectedFloor = null;
                  });
                },
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          const ThemeSwitcherIcon(),
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            onSelected: (floor) {
              setState(() {
                _selectedFloor = floor == 0 ? null : floor;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text('All Floors')),
              const PopupMenuItem(value: 1, child: Text('Floor 1')),
              const PopupMenuItem(value: 2, child: Text('Floor 2')),
              const PopupMenuItem(value: 3, child: Text('Floor 3')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Consumer2<ResourceProvider, RealtimeProvider>(
            builder: (context, resourceProvider, realtimeProvider, _) {
              if (resourceProvider.isLoading) {
                return const LoadingIndicator();
              }

              final resources = _selectedFloor != null
                  ? resourceProvider.resources
                      .where((r) => r.floor == _selectedFloor)
                      .toList()
                  : resourceProvider.resources;

              final stats = _calculateStats(resources);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total',
                          value: resources.length.toString(),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Available',
                          value: stats['available'].toString(),
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Unavailable',
                          value: stats['unavailable'].toString(),
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Maintenance',
                          value: stats['maintenance'].toString(),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Utilization chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resource Utilization',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _buildUtilizationChart(stats),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Floor breakdown
                  if (_selectedFloor == null) ...[
                    Text(
                      'Floor Breakdown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ..._buildFloorBreakdown(resourceProvider.resources),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Map<String, int> _calculateStats(List resources) {
    int available = 0;
    int unavailable = 0;
    int maintenance = 0;

    for (final resource in resources) {
      switch (resource.status.value) {
        case 'AVAILABLE':
          available++;
          break;
        case 'UNAVAILABLE':
          unavailable++;
          break;
        case 'MAINTENANCE':
          maintenance++;
          break;
      }
    }

    return {
      'available': available,
      'unavailable': unavailable,
      'maintenance': maintenance,
    };
  }

  Widget _buildUtilizationChart(Map<String, int> stats) {
    final total =
        stats['available']! + stats['unavailable']! + stats['maintenance']!;
    if (total == 0) {
      return const Center(child: Text('No data available'));
    }

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: stats['available']!.toDouble(),
            title:
                '${((stats['available']! / total) * 100).toStringAsFixed(1)}%',
            color: Colors.green,
            radius: 80,
          ),
          PieChartSectionData(
            value: stats['unavailable']!.toDouble(),
            title:
                '${((stats['unavailable']! / total) * 100).toStringAsFixed(1)}%',
            color: Colors.red,
            radius: 80,
          ),
          PieChartSectionData(
            value: stats['maintenance']!.toDouble(),
            title:
                '${((stats['maintenance']! / total) * 100).toStringAsFixed(1)}%',
            color: Colors.grey,
            radius: 80,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloorBreakdown(List resources) {
    final floors = <int>{};
    for (final resource in resources) {
      floors.add(resource.floor);
    }

    return floors.map((floor) {
      final floorResources = resources.where((r) => r.floor == floor).toList();
      final stats = _calculateStats(floorResources);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.layers),
          title: Text('Floor $floor'),
          subtitle: Text(
            'Available: ${stats['available']}, Unavailable: ${stats['unavailable']}, Maintenance: ${stats['maintenance']}',
          ),
          trailing: Text('${floorResources.length} resources'),
        ),
      );
    }).toList();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
