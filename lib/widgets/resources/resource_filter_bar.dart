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
  
  const ResourceFilterBar({
    super.key,
    this.selectedType,
    this.selectedFloor,
    this.selectedStatus,
    this.searchQuery = '',
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
                label: const Text('Type'),
                selected: selectedType != null,
                onSelected: (selected) {
                  onTypeChanged(selected ? ResourceType.studyRoom : null);
                },
              ),
              if (selectedType != null)
                FilterChip(
                  label: Text(selectedType!.value),
                  selected: true,
                  onSelected: (_) => onTypeChanged(null),
                ),
              // Floor filter
              FilterChip(
                label: const Text('Floor'),
                selected: selectedFloor != null,
                onSelected: (selected) {
                  onFloorChanged(selected ? 1 : null);
                },
              ),
              if (selectedFloor != null)
                FilterChip(
                  label: Text('Floor $selectedFloor'),
                  selected: true,
                  onSelected: (_) => onFloorChanged(null),
                ),
              // Status filter
              FilterChip(
                label: const Text('Status'),
                selected: selectedStatus != null,
                onSelected: (selected) {
                  onStatusChanged(selected ? ResourceStatus.available : null);
                },
              ),
              if (selectedStatus != null)
                FilterChip(
                  label: Text(selectedStatus!.value),
                  selected: true,
                  onSelected: (_) => onStatusChanged(null),
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
}

