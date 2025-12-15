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
  final TransformationController _transformationController =
      TransformationController();

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
    if (widget.resources.isEmpty) {
      return Container(
        width: 600,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No resources available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Load resources to see them on the floor plan',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate grid dimensions based on number of resources
    final resourceCount = widget.resources.length;
    final columns = (resourceCount / 3).ceil().clamp(3, 6);
    final rows = (resourceCount / columns).ceil();

    // Create a visual floor plan with rooms and corridors
    final planWidth = (columns * 120.0).clamp(600.0, 1000.0);
    final planHeight = (rows * 100.0).clamp(400.0, 800.0);

    return Container(
      width: planWidth,
      height: planHeight,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Floor plan background with rooms
          CustomPaint(
            size: Size(planWidth, planHeight),
            painter: _FloorPlanPainter(columns: columns, rows: rows),
          ),
          // Grid overlay
          CustomPaint(
            size: Size(planWidth, planHeight),
            painter: _GridPainter(columns: columns, rows: rows),
          ),
          // Resource markers positioned on the floor plan
          ...widget.resources.asMap().entries.map((entry) {
            final index = entry.key;
            final resource = entry.value;
            final col = index % columns;
            final row = index ~/ columns;

            return _ResourceMarker(
              resource: resource,
              position: Offset(
                (col * (planWidth / columns)) + (planWidth / columns / 2),
                (row * (planHeight / rows)) + (planHeight / rows / 2),
              ),
              onTap: () => widget.onResourceTap?.call(resource),
            );
          }),
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
  final Offset position;
  final VoidCallback? onTap;

  const _ResourceMarker({
    required this.resource,
    required this.position,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

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

    switch (resource.type) {
      case ResourceType.studyRoom:
      case ResourceType.groupRoom:
        icon = Icons.meeting_room;
        break;
      case ResourceType.computerStation:
        icon = Icons.computer;
        break;
      case ResourceType.seat:
        icon = Icons.chair;
        break;
    }

    return Positioned(
      left: position.dx - 30,
      top: position.dy - 30,
      child: GestureDetector(
        onTap: onTap,
        child: Tooltip(
          message:
              '${resource.name}\n${resource.type.value}\nFloor ${resource.floor}',
          preferBelow: false,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for floor plan grid
class _GridPainter extends CustomPainter {
  final int columns;
  final int rows;

  _GridPainter({required this.columns, required this.rows});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw vertical grid lines
    for (int i = 0; i <= columns; i++) {
      final x = (i * size.width / columns);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal grid lines
    for (int i = 0; i <= rows; i++) {
      final y = (i * size.height / rows);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) {
    return oldDelegate.columns != columns || oldDelegate.rows != rows;
  }
}

/// Custom painter for floor plan background (rooms, walls, etc.)
class _FloorPlanPainter extends CustomPainter {
  final int columns;
  final int rows;

  _FloorPlanPainter({required this.columns, required this.rows});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw some room outlines to make it look like a floor plan
    final roomPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw room rectangles aligned with the dynamic grid
    final roomWidth = size.width / columns;
    final roomHeight = size.height / rows;

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        final x = j * roomWidth;
        final y = i * roomHeight;

        // Draw room with padding
        const padding = 8.0;
        canvas.drawRect(
          Rect.fromLTWH(x + padding, y + padding, roomWidth - (padding * 2),
              roomHeight - (padding * 2)),
          roomPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(x + padding, y + padding, roomWidth - (padding * 2),
              roomHeight - (padding * 2)),
          paint,
        );
      }
    }

    // Draw corridors (horizontal) between rows, but only if there are multiple rows
    if (rows > 1) {
      final corridorPaint = Paint()
        ..color = Colors.grey[100]!
        ..style = PaintingStyle.fill;

      for (int i = 1; i < rows; i++) {
        final y = i * roomHeight;
        canvas.drawRect(
          Rect.fromLTWH(0, y - 15, size.width, 30),
          corridorPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FloorPlanPainter oldDelegate) {
    return oldDelegate.columns != columns || oldDelegate.rows != rows;
  }
}
