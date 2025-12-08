import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resource_provider.dart';
import '../../providers/realtime_provider.dart';
import '../../widgets/resources/floor_plan_widget.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../constants/route_names.dart';

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
        title: const Text('Floor Plan'),
        actions: [
          // Floor selector (if multiple floors)
          PopupMenuButton<int>(
            icon: const Icon(Icons.layers),
            onSelected: (floor) {
              setState(() {
                _selectedFloor = floor;
              });
              final resourceProvider =
                  Provider.of<ResourceProvider>(context, listen: false);
              resourceProvider.filterResources(floor: floor);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text('Floor 1')),
              const PopupMenuItem(value: 2, child: Text('Floor 2')),
              const PopupMenuItem(value: 3, child: Text('Floor 3')),
            ],
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

          return FloorPlanWidget(
            resources: resources,
            selectedFloor: _selectedFloor,
            onResourceTap: (resource) {
              _showResourceDetails(context, resource);
            },
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
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        RouteNames.createBooking,
                        arguments: resource.id,
                      );
                    },
                    child: const Text('Book Now'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
