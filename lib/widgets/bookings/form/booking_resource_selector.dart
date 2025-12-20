import 'package:flutter/material.dart';
import '../../../models/resource.dart';

class BookingResourceSelector extends StatefulWidget {
  final List<Resource>? resources;
  final Resource? selectedResource;
  final ValueChanged<Resource?> onChanged;

  const BookingResourceSelector({
    super.key,
    required this.resources,
    required this.selectedResource,
    required this.onChanged,
  });

  @override
  State<BookingResourceSelector> createState() => _BookingResourceSelectorState();
}

class _BookingResourceSelectorState extends State<BookingResourceSelector> {
  // Cache dropdown items to avoid rebuilding on every render
  List<DropdownMenuItem<Resource>>? _cachedItems;
  List<Resource>? _lastResourcesList;

  List<DropdownMenuItem<Resource>> _buildDropdownItems() {
    final resources = widget.resources ?? [];
    
    // Return cached items if resources list hasn't changed
    if (_cachedItems != null && 
        _lastResourcesList != null &&
        _lastResourcesList!.length == resources.length &&
        _listEquals(_lastResourcesList!, resources)) {
      return _cachedItems!;
    }

    // Build new items
    final items = resources.map<DropdownMenuItem<Resource>>((resource) {
      final isAvailable = resource.isAvailable;
      return DropdownMenuItem<Resource>(
        value: resource,
        enabled: isAvailable,
        child: Text(
          '${resource.name} - ${resource.type.value} (Floor ${resource.floor})',
          style: TextStyle(
            color: isAvailable ? null : Colors.grey,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
      );
    }).toList();

    // Cache items
    _cachedItems = items;
    _lastResourcesList = List<Resource>.from(resources);
    
    return items;
  }

  bool _listEquals(List<Resource> a, List<Resource> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].isAvailable != b[i].isAvailable) {
        return false;
      }
    }
    return true;
  }

  @override
  void didUpdateWidget(BookingResourceSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Invalidate cache if resources list changed
    if (oldWidget.resources != widget.resources) {
      _cachedItems = null;
      _lastResourcesList = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedResource == null) {
      final items = _buildDropdownItems();
      
      return DropdownButtonFormField<Resource>(
        decoration: const InputDecoration(
          labelText: 'Resource',
          border: OutlineInputBorder(),
          hintText: 'Select a resource',
        ),
        items: items,
        // Performance optimizations
        menuMaxHeight: 400, // Limit dropdown height to prevent lag
        itemHeight: 48, // Fixed item height for better performance
        isExpanded: true, // Prevent overflow issues
        onChanged: (resource) {
          if (resource != null && resource.isAvailable) {
            widget.onChanged(resource);
          } else if (resource != null && !resource.isAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${resource.name} is ${resource.status.value.toLowerCase()} and cannot be booked'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        validator: (value) {
          if (value == null) {
            return 'Resource is required';
          }
          if (!value.isAvailable) {
            return 'This resource is not available for booking';
          }
          return null;
        },
      );
    } else {
      return Card(
        color: widget.selectedResource!.isAvailable ? null : Colors.red[50],
        child: ListTile(
          leading: widget.selectedResource!.isAvailable
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.cancel, color: Colors.red),
          title: Text(widget.selectedResource!.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${widget.selectedResource!.type.value} - Floor ${widget.selectedResource!.floor}'),
              if (!widget.selectedResource!.isAvailable)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Status: ${widget.selectedResource!.status.value} - Cannot be booked',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              widget.onChanged(null);
            },
          ),
        ),
      );
    }
  }
}
