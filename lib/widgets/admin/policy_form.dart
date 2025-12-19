import 'package:flutter/material.dart';
import '../../models/policy.dart';
import '../../core/mixins/validation_mixin.dart';

/// Policy form widget for creating/updating policies
/// Matches backend CreatePolicyRequest structure
class PolicyForm extends StatefulWidget {
  final Policy? initialPolicy;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;

  const PolicyForm({
    super.key,
    this.initialPolicy,
    this.onCancel,
    this.isLoading = false,
    required this.onSubmit,
  });

  @override
  State<PolicyForm> createState() => _PolicyFormState();
}

class _PolicyFormState extends State<PolicyForm> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _maxDurationController = TextEditingController();
  final _maxAdvanceDaysController = TextEditingController();
  final _maxConcurrentController = TextEditingController();
  final _gracePeriodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPolicy != null) {
      final policy = widget.initialPolicy!;
      _nameController.text = policy.name;
      _maxDurationController.text = policy.maxDurationMinutes?.toString() ?? '';
      _maxAdvanceDaysController.text = policy.maxAdvanceDays?.toString() ?? '';
      _maxConcurrentController.text = policy.maxConcurrentBookings?.toString() ?? '';
      _gracePeriodController.text = policy.gracePeriodMinutes?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxDurationController.dispose();
    _maxAdvanceDaysController.dispose();
    _maxConcurrentController.dispose();
    _gracePeriodController.dispose();
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
                labelText: 'Policy Name *',
                border: OutlineInputBorder(),
                hintText: 'e.g., Default Booking Policy',
              ),
              validator: (value) => validateRequired(value, fieldName: 'Name'),
            ),
            const SizedBox(height: 16),

            // Max Duration field
            TextFormField(
              controller: _maxDurationController,
              decoration: const InputDecoration(
                labelText: 'Max Duration (minutes) *',
                border: OutlineInputBorder(),
                hintText: 'e.g., 120 (2 hours)',
                helperText: 'Maximum booking duration in minutes',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Max duration is required';
                }
                final num = int.tryParse(value);
                if (num == null || num < 1) {
                  return 'Must be at least 1 minute';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Max Advance Days field
            TextFormField(
              controller: _maxAdvanceDaysController,
              decoration: const InputDecoration(
                labelText: 'Max Advance Days *',
                border: OutlineInputBorder(),
                hintText: 'e.g., 7',
                helperText: 'How many days in advance users can book',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Max advance days is required';
                }
                final num = int.tryParse(value);
                if (num == null || num < 0) {
                  return 'Must be 0 or greater';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Max Concurrent Bookings field
            TextFormField(
              controller: _maxConcurrentController,
              decoration: const InputDecoration(
                labelText: 'Max Concurrent Bookings *',
                border: OutlineInputBorder(),
                hintText: 'e.g., 3',
                helperText: 'Maximum active bookings per user',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Max concurrent bookings is required';
                }
                final num = int.tryParse(value);
                if (num == null || num < 1) {
                  return 'Must be at least 1';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Grace Period field
            TextFormField(
              controller: _gracePeriodController,
              decoration: const InputDecoration(
                labelText: 'Grace Period (minutes) *',
                border: OutlineInputBorder(),
                hintText: 'e.g., 15',
                helperText: 'Minutes after start time to check in',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Grace period is required';
                }
                final num = int.tryParse(value);
                if (num == null || num < 0) {
                  return 'Must be 0 or greater';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Policy summary card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Policy Summary',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(_getPolicySummary()),
                  ],
                ),
              ),
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
                  : Text(widget.initialPolicy == null
                      ? 'Create Policy'
                      : 'Update Policy'),
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

  String _getPolicySummary() {
    final duration = _maxDurationController.text;
    final advance = _maxAdvanceDaysController.text;
    final concurrent = _maxConcurrentController.text;
    final grace = _gracePeriodController.text;

    if (duration.isEmpty && advance.isEmpty && concurrent.isEmpty && grace.isEmpty) {
      return 'Fill in the form to see summary';
    }

    final parts = <String>[];
    if (duration.isNotEmpty) {
      final mins = int.tryParse(duration) ?? 0;
      if (mins >= 60) {
        parts.add('Max ${(mins / 60).toStringAsFixed(1)} hours per booking');
      } else {
        parts.add('Max $mins minutes per booking');
      }
    }
    if (advance.isNotEmpty) {
      parts.add('Book up to $advance days ahead');
    }
    if (concurrent.isNotEmpty) {
      parts.add('Max $concurrent active bookings');
    }
    if (grace.isNotEmpty) {
      parts.add('$grace min grace period for check-in');
    }

    return parts.join('\n');
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = {
      'name': _nameController.text.trim(),
      'maxDurationMinutes': int.parse(_maxDurationController.text.trim()),
      'maxAdvanceDays': int.parse(_maxAdvanceDaysController.text.trim()),
      'maxConcurrentBookings': int.parse(_maxConcurrentController.text.trim()),
      'gracePeriodMinutes': int.parse(_gracePeriodController.text.trim()),
    };

    widget.onSubmit(request);
  }
}
