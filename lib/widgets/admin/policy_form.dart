import 'package:flutter/material.dart';
import '../../models/policy.dart';
import '../../core/mixins/validation_mixin.dart';

/// Policy form widget for creating/updating policies
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
  final _descriptionController = TextEditingController();
  final _ruleValueController = TextEditingController();
  
  RuleType _selectedRuleType = RuleType.maxDurationHours;
  bool _active = true;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialPolicy != null) {
      final policy = widget.initialPolicy!;
      _nameController.text = policy.name;
      _descriptionController.text = policy.description ?? '';
      _ruleValueController.text = policy.ruleValue;
      _selectedRuleType = policy.ruleType;
      _active = policy.active;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ruleValueController.dispose();
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
                labelText: 'Policy Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Maximum Booking Duration',
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
                hintText: 'Policy description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Rule type dropdown
            DropdownButtonFormField<RuleType>(
              decoration: const InputDecoration(
                labelText: 'Rule Type',
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedRuleType,
              items: RuleType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.value.replaceAll('_', ' ')),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRuleType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Rule value field
            TextFormField(
              controller: _ruleValueController,
              decoration: InputDecoration(
                labelText: 'Rule Value',
                border: const OutlineInputBorder(),
                hintText: _getRuleValueHint(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => validateNumeric(value, fieldName: 'Rule Value'),
            ),
            const SizedBox(height: 16),
            // Active switch
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Enable this policy'),
              value: _active,
              onChanged: (value) {
                setState(() {
                  _active = value;
                });
              },
            ),
            // Policy preview
            if (_nameController.text.isNotEmpty && _ruleValueController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Policy Preview',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(_getPolicyPreview()),
                    ],
                  ),
                ),
              ),
            ],
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
                  : Text(widget.initialPolicy == null ? 'Create Policy' : 'Update Policy'),
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
  
  String _getRuleValueHint() {
    switch (_selectedRuleType) {
      case RuleType.maxDurationHours:
        return 'e.g., 4 (hours)';
      case RuleType.advanceBookingDays:
        return 'e.g., 7 (days)';
      case RuleType.maxConcurrentBookings:
        return 'e.g., 3';
      case RuleType.gracePeriodMinutes:
        return 'e.g., 15 (minutes)';
      case RuleType.maxBookingsPerDay:
        return 'e.g., 2';
    }
  }
  
  String _getPolicyPreview() {
    if (_nameController.text.isEmpty || _ruleValueController.text.isEmpty) {
      return 'Fill in the form to see preview';
    }
    
    final value = _ruleValueController.text;
    final type = _selectedRuleType.value.replaceAll('_', ' ').toLowerCase();
    
    return 'This policy sets the $type to $value.';
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
      'ruleType': _selectedRuleType.value,
      'ruleValue': _ruleValueController.text.trim(),
      'active': _active,
    };
    
    widget.onSubmit(request);
  }
}

