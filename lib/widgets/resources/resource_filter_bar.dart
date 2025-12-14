import 'package:flutter/material.dart';
import '../../models/resource.dart';

/// Resource filter bar widget
class ResourceFilterBar extends StatelessWidget {
  final ResourceType? selectedType;
  final int? selectedFloor;
  final ResourceStatus? selectedStatus;
  final String searchQuery;
  final Function(ResourceType?) onTypeChanged;
  final Function(int?) onFloorChanged;
  final Function(ResourceStatus?) onStatusChanged;
  final Function(String) onSearchChanged;
  final VoidCallback onClearFilters;
  final List<int>? availableFloors; // Optional: list of available floors from resources
  
  const ResourceFilterBar({
    super.key,
    this.selectedType,
    this.selectedFloor,
    this.selectedStatus,
    this.searchQuery = '',
    this.availableFloors,
    required this.onTypeChanged,
    required this.onFloorChanged,
    required this.onStatusChanged,
    required this.onSearchChanged,
    required this.onClearFilters,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search resources...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => onSearchChanged(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Type filter
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Type'),
                    if (selectedType != null) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.check_circle, size: 16, color: Theme.of(context).colorScheme.primary),
                    ],
                  ],
                ),
                selected: selectedType != null,
                onSelected: (_) => _showTypeFilterDialog(context),
              ),
              if (selectedType != null)
                FilterChip(
                  label: Text(selectedType!.value),
                  selected: true,
                  onSelected: (_) => onTypeChanged(null),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => onTypeChanged(null),
                ),
              // Floor filter
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Floor'),
                    if (selectedFloor != null) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.check_circle, size: 16, color: Theme.of(context).colorScheme.primary),
                    ],
                  ],
                ),
                selected: selectedFloor != null,
                onSelected: (_) => _showFloorFilterDialog(context),
              ),
              if (selectedFloor != null)
                FilterChip(
                  label: Text('Floor $selectedFloor'),
                  selected: true,
                  onSelected: (_) => onFloorChanged(null),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => onFloorChanged(null),
                ),
              // Status filter
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Status'),
                    if (selectedStatus != null) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.check_circle, size: 16, color: Theme.of(context).colorScheme.primary),
                    ],
                  ],
                ),
                selected: selectedStatus != null,
                onSelected: (_) => _showStatusFilterDialog(context),
              ),
              if (selectedStatus != null)
                FilterChip(
                  label: Text(selectedStatus!.value),
                  selected: true,
                  onSelected: (_) => onStatusChanged(null),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => onStatusChanged(null),
                ),
              // Clear filters button
              if (selectedType != null || selectedFloor != null || selectedStatus != null || searchQuery.isNotEmpty)
                ActionChip(
                  label: const Text('Clear All'),
                  avatar: const Icon(Icons.clear, size: 18),
                  onPressed: onClearFilters,
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Show type filter selection dialog
  void _showTypeFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Select Resource Type',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ...ResourceType.values.map((type) {
              final isSelected = selectedType == type;
              return ListTile(
                leading: Icon(
                  _getTypeIcon(type),
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
                title: Text(type.value),
                trailing: isSelected
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                selected: isSelected,
                onTap: () {
                  Navigator.pop(context);
                  onTypeChanged(isSelected ? null : type);
                },
              );
            }),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear Filter'),
              onTap: () {
                Navigator.pop(context);
                onTypeChanged(null);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show floor filter selection dialog
  void _showFloorFilterDialog(BuildContext context) {
    // Get available floors (1-10 as default, or use provided list)
    final floors = availableFloors ?? List.generate(10, (index) => index + 1);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Select Floor',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: floors.length,
                itemBuilder: (context, index) {
                  final floor = floors[index];
                  final isSelected = selectedFloor == floor;
                  return ListTile(
                    leading: Icon(
                      Icons.layers,
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    ),
                    title: Text('Floor $floor'),
                    trailing: isSelected
                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                        : null,
                    selected: isSelected,
                    onTap: () {
                      Navigator.pop(context);
                      onFloorChanged(isSelected ? null : floor);
                    },
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear Filter'),
              onTap: () {
                Navigator.pop(context);
                onFloorChanged(null);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show status filter selection dialog
  void _showStatusFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Select Status',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ...ResourceStatus.values.map((status) {
              final isSelected = selectedStatus == status;
              return ListTile(
                leading: Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                ),
                title: Text(status.value),
                trailing: isSelected
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                selected: isSelected,
                onTap: () {
                  Navigator.pop(context);
                  onStatusChanged(isSelected ? null : status);
                },
              );
            }),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear Filter'),
              onTap: () {
                Navigator.pop(context);
                onStatusChanged(null);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Get icon for resource type
  IconData _getTypeIcon(ResourceType type) {
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
  
  /// Get icon for resource status
  IconData _getStatusIcon(ResourceStatus status) {
    switch (status) {
      case ResourceStatus.available:
        return Icons.check_circle;
      case ResourceStatus.unavailable:
        return Icons.cancel;
      case ResourceStatus.maintenance:
        return Icons.build;
    }
  }
  
  /// Get color for resource status
  Color _getStatusColor(ResourceStatus status) {
    switch (status) {
      case ResourceStatus.available:
        return Colors.green;
      case ResourceStatus.unavailable:
        return Colors.red;
      case ResourceStatus.maintenance:
        return Colors.grey;
    }
  }
}

