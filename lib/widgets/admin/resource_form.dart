import 'package:flutter/material.dart';
import '../../models/resource.dart';
import '../../core/mixins/validation_mixin.dart';

/// Resource form widget for creating/updating resources
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
  final _descriptionController = TextEditingController();
  final _floorController = TextEditingController();
  final _capacityController = TextEditingController();
  
  ResourceType _selectedType = ResourceType.studyRoom;
  ResourceStatus _selectedStatus = ResourceStatus.available;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialResource != null) {
      final resource = widget.initialResource!;
      _nameController.text = resource.name;
      _descriptionController.text = resource.description ?? '';
      _floorController.text = resource.floor.toString();
      _capacityController.text = resource.capacity.toString();
      _selectedType = resource.type;
      _selectedStatus = resource.status;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _floorController.dispose();
    _capacityController.dispose();
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
                labelText: 'Resource Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Study Room 101',
              ),
              validator: (value) => validateRequired(value, fieldName: 'Name'),
            ),
            const SizedBox(height: 16),
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'Optional description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Type dropdown
            DropdownButtonFormField<ResourceType>(
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedType,
              items: ResourceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.value),
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
            // Floor field
            TextFormField(
              controller: _floorController,
              decoration: const InputDecoration(
                labelText: 'Floor',
                border: OutlineInputBorder(),
                hintText: 'e.g., 1',
              ),
              keyboardType: TextInputType.number,
              validator: (value) => validatePositiveInteger(value, fieldName: 'Floor'),
            ),
            const SizedBox(height: 16),
            // Capacity field
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacity',
                border: OutlineInputBorder(),
                hintText: 'e.g., 4',
              ),
              keyboardType: TextInputType.number,
              validator: (value) => validatePositiveInteger(value, fieldName: 'Capacity'),
            ),
            const SizedBox(height: 16),
            // Status dropdown
            DropdownButtonFormField<ResourceStatus>(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedStatus,
              items: ResourceStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.value),
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
            const SizedBox(height: 24),
            // Submit button
            ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.initialResource == null ? 'Create Resource' : 'Update Resource'),
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
  
  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final request = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'type': _selectedType.value,
      'floor': int.parse(_floorController.text),
      'capacity': int.parse(_capacityController.text),
      'status': _selectedStatus.value,
    };
    
    widget.onSubmit(request);
  }
}

