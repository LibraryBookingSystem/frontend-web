import 'package:flutter/material.dart';
import '../../models/resource.dart';
import '../../core/mixins/validation_mixin.dart';
import 'form/booking_resource_selector.dart';
import 'form/booking_date_time_fields.dart';
import 'form/booking_duration_display.dart';

/// Booking form widget for creating/updating bookings
class BookingForm extends StatefulWidget {
  final Resource? selectedResource;
  final List<Resource>? resources;
  final DateTime? initialStartTime;
  final DateTime? initialEndTime;
  final Function(DateTime startTime, DateTime endTime, int resourceId) onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;

  const BookingForm({
    super.key,
    this.selectedResource,
    this.resources,
    this.initialStartTime,
    this.initialEndTime,
    this.onCancel,
    required this.onSubmit,
    this.isLoading = false,
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
          BookingResourceSelector(
            resources: widget.resources,
            selectedResource: _selectedResource,
            onChanged: (resource) {
              setState(() {
                _selectedResource = resource;
              });
            },
          ),
          const SizedBox(height: 16),
          // Date and Time Fields
          BookingDateTimeFields(
            startDate: _startDate,
            startTime: _startTime,
            endDate: _endDate,
            endTime: _endTime,
            onStartDateChanged: (date) {
              setState(() {
                _startDate = date;
              });
            },
            onStartTimeChanged: (time) {
              setState(() {
                _startTime = time;
              });
            },
            onEndDateChanged: (date) {
              setState(() {
                _endDate = date;
              });
            },
            onEndTimeChanged: (time) {
              setState(() {
                _endTime = time;
              });
            },
          ),
          // Duration display
          BookingDurationDisplay(
            startDate: _startDate,
            startTime: _startTime,
            endDate: _endDate,
            endTime: _endTime,
          ),
          const SizedBox(height: 24),
          // Submit button
          ElevatedButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Create Booking'),
          ),
          if (widget.onCancel != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.isLoading ? null : widget.onCancel,
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
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

    // Validate start time is not in the past
    if (start.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start time cannot be in the past'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
