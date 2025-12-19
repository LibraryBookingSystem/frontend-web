import 'package:flutter/material.dart';
import '../../models/resource.dart';
import '../../core/mixins/validation_mixin.dart';

/// Resource form widget for creating/updating resources
/// Matches backend CreateResourceRequest structure
class ResourceForm extends StatefulWidget {
  final Resource? initialResource;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;

  const ResourceForm({
    super.key,
    this.initialResource,
    this.onCancel,
    this.isLoading = false,
    required this.onSubmit,
  });

  @override
  State<ResourceForm> createState() => _ResourceFormState();
}

class _ResourceFormState extends State<ResourceForm> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _floorController = TextEditingController();
  final _capacityController = TextEditingController();
  final _locationXController = TextEditingController();
  final _locationYController = TextEditingController();

  ResourceType _selectedType = ResourceType.studyRoom;
  ResourceStatus _selectedStatus = ResourceStatus.available;

  @override
  void initState() {
    super.initState();
    if (widget.initialResource != null) {
      final resource = widget.initialResource!;
      _nameController.text = resource.name;
      _floorController.text = resource.floor.toString();
      _capacityController.text = resource.capacity.toString();
      _locationXController.text = resource.locationX?.toString() ?? '';
      _locationYController.text = resource.locationY?.toString() ?? '';
      _selectedType = resource.type;
      _selectedStatus = resource.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _floorController.dispose();
    _capacityController.dispose();
    _locationXController.dispose();
    _locationYController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Resource Name *',
                border: OutlineInputBorder(),
                hintText: 'e.g., Study Room 101',
              ),
              validator: (value) => validateRequired(value, fieldName: 'Name'),
            ),
            const SizedBox(height: 16),

            // Type dropdown
            DropdownButtonFormField<ResourceType>(
              decoration: const InputDecoration(
                labelText: 'Type *',
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedType,
              items: ResourceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeDisplayName(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Floor and Capacity in a row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _floorController,
                    decoration: const InputDecoration(
                      labelText: 'Floor *',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 1',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Floor is required';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Must be 0 or greater';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity *',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 4',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Capacity is required';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 1) {
                        return 'Must be at least 1';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location fields (optional)
            Text(
              'Location on Floor Plan (optional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _locationXController,
                    decoration: const InputDecoration(
                      labelText: 'X Position',
                      border: OutlineInputBorder(),
                      hintText: '0.0 - 1.0',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = double.tryParse(value);
                        if (num == null) {
                          return 'Invalid number';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _locationYController,
                    decoration: const InputDecoration(
                      labelText: 'Y Position',
                      border: OutlineInputBorder(),
                      hintText: '0.0 - 1.0',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = double.tryParse(value);
                        if (num == null) {
                          return 'Invalid number';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status dropdown (only for editing)
            if (widget.initialResource != null) ...[
              DropdownButtonFormField<ResourceStatus>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedStatus,
                items: ResourceStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusDisplayName(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 8),

            // Submit button
            ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.initialResource == null
                      ? 'Create Resource'
                      : 'Update Resource'),
            ),
            if (widget.onCancel != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTypeDisplayName(ResourceType type) {
    switch (type) {
      case ResourceType.studyRoom:
        return 'Study Room';
      case ResourceType.groupRoom:
        return 'Group Room';
      case ResourceType.computerStation:
        return 'Computer Station';
      case ResourceType.seat:
        return 'Seat';
    }
  }

  String _getStatusDisplayName(ResourceStatus status) {
    switch (status) {
      case ResourceStatus.available:
        return 'Available';
      case ResourceStatus.unavailable:
        return 'Unavailable';
      case ResourceStatus.maintenance:
        return 'Maintenance';
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = <String, dynamic>{
      'name': _nameController.text.trim(),
      'type': _selectedType.value,
      'floor': int.parse(_floorController.text),
      'capacity': int.parse(_capacityController.text),
    };

    // Add optional location fields
    if (_locationXController.text.isNotEmpty) {
      request['locationX'] = double.parse(_locationXController.text);
    }
    if (_locationYController.text.isNotEmpty) {
      request['locationY'] = double.parse(_locationYController.text);
    }

    // Add status only for updates
    if (widget.initialResource != null) {
      request['status'] = _selectedStatus.value;
    }

    widget.onSubmit(request);
  }
}
