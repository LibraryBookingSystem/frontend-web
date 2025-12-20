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
        mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 16),
                // Duration Presets
                Text(
                  'Quick Duration Presets',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDurationPreset('30 min', 30),
                    _buildDurationPreset('1 hour', 60),
                    _buildDurationPreset('2 hours', 120),
                    _buildDurationPreset('4 hours', 240),
                    _buildDurationPreset('8 hours', 480),
                    _buildDurationPreset('24 hours', 1440),
                  ],
                ),
                const SizedBox(height: 16),
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
        const SnackBar(
            content: Text('Please fill in all fields'),
            duration: Duration(seconds: 3)),
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

    // Create DateTime objects in local timezone (user selects times in local timezone)
    // These will be converted to UTC when sent to backend via formatDateTime()
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

    // Validate start time is not in the past (compare in local timezone)
    final now = DateTime.now();
    if (start.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start time cannot be in the past'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validate time range
    final validationError = validateTimeRange(start, end);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(validationError),
            duration: const Duration(seconds: 3)),
      );
      return;
    }

    widget.onSubmit(start, end, _selectedResource!.id);
  }

  Widget _buildDurationPreset(String label, int durationMinutes) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        // Auto-set start time to now if not set
        if (_startDate == null || _startTime == null) {
          final now = DateTime.now();
          setState(() {
            _startDate = DateTime(now.year, now.month, now.day);
            _startTime = TimeOfDay.fromDateTime(now);
          });
        }

        // Calculate end time based on duration
        if (_startDate != null && _startTime != null) {
          final startDateTime = DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
            _startTime!.hour,
            _startTime!.minute,
          );
          final endDateTime =
              startDateTime.add(Duration(minutes: durationMinutes));

          setState(() {
            _endDate =
                DateTime(endDateTime.year, endDateTime.month, endDateTime.day);
            _endTime = TimeOfDay.fromDateTime(endDateTime);
          });
        }
      },
    );
  }
}
