import 'package:flutter/material.dart';
import '../../../models/resource.dart';

class BookingResourceSelector extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (selectedResource == null) {
      return DropdownButtonFormField<Resource>(
        decoration: const InputDecoration(
          labelText: 'Resource',
          border: OutlineInputBorder(),
        ),
        items: (resources ?? []).map((resource) {
          final isAvailable = resource.isAvailable;
          return DropdownMenuItem<Resource>(
            value: resource,
            enabled: isAvailable,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${resource.name} - ${resource.type.value} (Floor ${resource.floor})',
                    style: TextStyle(
                      color: isAvailable ? null : Colors.grey,
                    ),
                  ),
                ),
                if (!isAvailable)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      resource.status.value,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (resource) {
          if (resource != null && resource.isAvailable) {
            onChanged(resource);
          } else if (resource != null && !resource.isAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${resource.name} is ${resource.status.value.toLowerCase()} and cannot be booked'),
                backgroundColor: Colors.red,
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
        color: selectedResource!.isAvailable ? null : Colors.red[50],
        child: ListTile(
          leading: selectedResource!.isAvailable
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.cancel, color: Colors.red),
          title: Text(selectedResource!.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${selectedResource!.type.value} - Floor ${selectedResource!.floor}'),
              if (!selectedResource!.isAvailable)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Status: ${selectedResource!.status.value} - Cannot be booked',
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
              onChanged(null);
            },
          ),
        ),
      );
    }
  }
}
