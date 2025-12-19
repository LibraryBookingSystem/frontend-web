import 'package:flutter/material.dart';
import '../../../core/utils/date_utils.dart' as date_utils;

class BookingDurationDisplay extends StatelessWidget {
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;

  const BookingDurationDisplay({
    super.key,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    if (startDate != null &&
        startTime != null &&
        endDate != null &&
        endTime != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor.withValues(alpha: 0.5)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Duration',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _calculateDuration(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _calculateDuration() {
    if (startDate == null ||
        startTime == null ||
        endDate == null ||
        endTime == null) {
      return 'Select dates and times';
    }

    final start = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    final end = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    final duration = end.difference(start);
    return date_utils.AppDateUtils.formatDuration(duration);
  }
}
