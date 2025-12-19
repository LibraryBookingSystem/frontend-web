import 'package:flutter/material.dart';
import '../../../core/utils/date_utils.dart' as date_utils;

class BookingDateTimeFields extends StatelessWidget {
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<TimeOfDay?> onStartTimeChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final ValueChanged<TimeOfDay?> onEndTimeChanged;

  const BookingDateTimeFields({
    super.key,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.onStartDateChanged,
    required this.onStartTimeChanged,
    required this.onEndDateChanged,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Start date
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Start Date',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: startDate != null
                ? date_utils.AppDateUtils.formatDate(startDate!)
                : '',
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              onStartDateChanged(date);
            }
          },
          validator: (value) {
            if (startDate == null) {
              return 'Date is required';
            }
            final today = DateTime.now();
            final selectedDate =
                DateTime(startDate!.year, startDate!.month, startDate!.day);
            final todayDate = DateTime(today.year, today.month, today.day);
            if (selectedDate.isBefore(todayDate)) {
              return 'Date cannot be in the past';
            }
            return null;
          },
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
            text: startTime != null ? startTime!.format(context) : '',
          ),
          readOnly: true,
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: startTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              onStartTimeChanged(time);
            }
          },
          validator: (value) =>
              startTime == null ? 'Start time is required' : null,
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
            text: endDate != null
                ? date_utils.AppDateUtils.formatDate(endDate!)
                : '',
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: endDate ?? startDate ?? DateTime.now(),
              firstDate: startDate ?? DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              onEndDateChanged(date);
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
            text: endTime != null ? endTime!.format(context) : '',
          ),
          readOnly: true,
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: endTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              onEndTimeChanged(time);
            }
          },
          validator: (value) => endTime == null ? 'End time is required' : null,
        ),
      ],
    );
  }
}
