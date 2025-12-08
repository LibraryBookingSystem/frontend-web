import 'package:flutter/material.dart';
import '../../models/resource.dart';

/// Floor plan widget with SVG rendering and interactivity
class FloorPlanWidget extends StatefulWidget {
  final List<Resource> resources;
  final Function(Resource)? onResourceTap;
  final int? selectedFloor;
  
  const FloorPlanWidget({
    super.key,
    required this.resources,
    this.onResourceTap,
    this.selectedFloor,
  });
  
  @override
  State<FloorPlanWidget> createState() => _FloorPlanWidgetState();
}

class _FloorPlanWidgetState extends State<FloorPlanWidget> {
  final TransformationController _transformationController = TransformationController();
  
  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Legend
        _buildLegend(),
        const SizedBox(height: 16),
        // Floor plan with zoom/pan
        Expanded(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: _buildFloorPlan(),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(color: Colors.green, label: 'Available'),
          SizedBox(width: 16),
          _LegendItem(color: Colors.red, label: 'Unavailable'),
          SizedBox(width: 16),
          _LegendItem(color: Colors.grey, label: 'Maintenance'),
        ],
      ),
    );
  }
  
  Widget _buildFloorPlan() {
    // This is a placeholder - in a real app, you would load an SVG file
    // and overlay resource markers on it
    return Container(
      width: 400,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Placeholder SVG or image
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Floor Plan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'SVG floor plan would be rendered here',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // Resource markers
          ...widget.resources.map((resource) => _ResourceMarker(
            resource: resource,
            onTap: () => widget.onResourceTap?.call(resource),
          )),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  
  const _LegendItem({
    required this.color,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ResourceMarker extends StatelessWidget {
  final Resource resource;
  final VoidCallback? onTap;
  
  const _ResourceMarker({
    required this.resource,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    Color color;
    switch (resource.status) {
      case ResourceStatus.available:
        color = Colors.green;
        break;
      case ResourceStatus.unavailable:
        color = Colors.red;
        break;
      case ResourceStatus.maintenance:
        color = Colors.grey;
        break;
    }
    
    // Position would be calculated based on resource location data
    // For now, using a simple grid layout
    final position = Offset(
      (resource.id % 5) * 80.0 + 40,
      (resource.id ~/ 5) * 60.0 + 30,
    );
    
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: onTap,
        child: Tooltip(
          message: resource.name,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

