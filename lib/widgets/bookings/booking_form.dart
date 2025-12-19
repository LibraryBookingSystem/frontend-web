import 'package:flutter/material.dart';
import '../../models/resource.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../core/mixins/validation_mixin.dart';

/// Booking form widget for creating/updating bookings
class BookingForm extends StatefulWidget {
  final Resource? selectedResource;
  final List<Resource>? resources;
  final DateTime? initialStartTime;
  final DateTime? initialEndTime;
  final Function(DateTime startTime, DateTime endTime, int resourceId) onSubmit;
  final VoidCallback? onCancel;
  
  const BookingForm({
    super.key,
    this.selectedResource,
    this.resources,
    this.initialStartTime,
    this.initialEndTime,
    this.onCancel,
    required this.onSubmit,
  });
  
  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  Resource? _selectedResource;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  
  @override
  void initState() {
    super.initState();
    _selectedResource = widget.selectedResource;
    if (widget.initialStartTime != null) {
      _startDate = DateTime(
        widget.initialStartTime!.year,
        widget.initialStartTime!.month,
        widget.initialStartTime!.day,
      );
      _startTime = TimeOfDay.fromDateTime(widget.initialStartTime!);
    }
    if (widget.initialEndTime != null) {
      _endDate = DateTime(
        widget.initialEndTime!.year,
        widget.initialEndTime!.month,
        widget.initialEndTime!.day,
      );
      _endTime = TimeOfDay.fromDateTime(widget.initialEndTime!);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Resource selection
          if (_selectedResource == null)
            DropdownButtonFormField<Resource>(
              decoration: const InputDecoration(
                labelText: 'Resource',
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              items: (widget.resources ?? [])
                  .map((resource) {
                    final isAvailable = resource.isAvailable;
                    return DropdownMenuItem<Resource>(
                      value: resource,
                      enabled: isAvailable,
                      child: Text(
                        '${resource.name} - ${resource.type.value} (Floor ${resource.floor})${!isAvailable ? ' - ${resource.status.value}' : ''}',
                        style: TextStyle(
                          color: isAvailable ? null : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  })
                  .toList(),
              onChanged: (resource) {
                if (resource != null && resource.isAvailable) {
                  setState(() {
                    _selectedResource = resource;
                  });
                } else if (resource != null && !resource.isAvailable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${resource.name} is ${resource.status.value.toLowerCase()} and cannot be booked'),
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
            )
          else
            Card(
              color: _selectedResource!.isAvailable ? null : Colors.red[50],
              child: ListTile(
                leading: _selectedResource!.isAvailable
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
                title: Text(_selectedResource!.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_selectedResource!.type.value} - Floor ${_selectedResource!.floor}'),
                    if (!_selectedResource!.isAvailable)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Status: ${_selectedResource!.status.value} - Cannot be booked',
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
                    setState(() {
                      _selectedResource = null;
                    });
                  },
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Start date
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Start Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            controller: TextEditingController(
              text: _startDate != null ? date_utils.AppDateUtils.formatDate(_startDate!) : '',
            ),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _startDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _startDate = date;
                });
              }
            },
            validator: (value) => validateDateNotPast(_startDate),
          ),
          const SizedBox(height: 16),
          // Start time
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Start Time',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.access_time),
            ),
            controller: TextEditingController(
              text: _startTime != null
                  ? _startTime!.format(context)
                  : '',
            ),
            readOnly: true,
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime ?? TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _startTime = time;
                });
              }
            },
            validator: (value) => _startTime == null ? 'Start time is required' : null,
          ),
          const SizedBox(height: 16),
          // End date
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'End Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            controller: TextEditingController(
              text: _endDate != null ? date_utils.AppDateUtils.formatDate(_endDate!) : '',
            ),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _endDate ?? _startDate ?? DateTime.now(),
                firstDate: _startDate ?? DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _endDate = date;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          // End time
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'End Time',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.access_time),
            ),
            controller: TextEditingController(
              text: _endTime != null ? _endTime!.format(context) : '',
            ),
            readOnly: true,
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime ?? TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _endTime = time;
                });
              }
            },
            validator: (value) => _endTime == null ? 'End time is required' : null,
          ),
          // Duration display
          if (_startDate != null && _startTime != null && _endDate != null && _endTime != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Duration',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _calculateDuration(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Submit button
          ElevatedButton(
            onPressed: _handleSubmit,
            child: const Text('Create Booking'),
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
    );
  }
  
  String _calculateDuration() {
    if (_startDate == null || _startTime == null || _endDate == null || _endTime == null) {
      return 'Select dates and times';
    }
    
    final start = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    
    final end = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
    
    final duration = end.difference(start);
    return date_utils.AppDateUtils.formatDuration(duration);
  }
  
  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedResource == null ||
        _startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    
    // Validate resource availability
    if (!_selectedResource!.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedResource!.name} is ${_selectedResource!.status.value.toLowerCase()} and cannot be booked',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    final start = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    
    final end = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
    
    // Validate time range
    final validationError = validateTimeRange(start, end);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }
    
    widget.onSubmit(start, end, _selectedResource!.id);
  }
}

