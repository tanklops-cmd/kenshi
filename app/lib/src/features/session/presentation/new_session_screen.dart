import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';

class NewSessionScreen extends ConsumerStatefulWidget {
  const NewSessionScreen({super.key});

  @override
  ConsumerState<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends ConsumerState<NewSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _trainingDate;
  SessionType? _sessionType;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectTrainingDate(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _trainingDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      field.didChange(selectedDate);
      setState(() => _trainingDate = selectedDate);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final session = await ref
          .read(sessionsProvider.notifier)
          .createSession(
            trainingDate: _trainingDate!,
            sessionType: _sessionType!,
            title: _titleController.text,
            location: _locationController.text,
          );

      if (mounted) {
        context.replace(AppRoutes.sessionDetailLocation(session.id));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session could not be saved.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Session')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            children: [
              FormField<DateTime>(
                key: const ValueKey('trainingDateField'),
                initialValue: _trainingDate,
                validator: (value) =>
                    value == null ? 'Training date is required.' : null,
                builder: (field) {
                  final date = field.value;

                  return InkWell(
                    onTap: _isSaving
                        ? null
                        : () async => _selectTrainingDate(field),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Training Date',
                        errorText: field.errorText,
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        date == null
                            ? 'Select a date'
                            : localizations.formatMediumDate(date),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SessionType>(
                key: const ValueKey('sessionTypeField'),
                initialValue: _sessionType,
                decoration: const InputDecoration(
                  labelText: 'Session Type',
                  border: OutlineInputBorder(),
                ),
                items: SessionType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isSaving
                    ? null
                    : (value) => setState(() => _sessionType = value),
                validator: (value) =>
                    value == null ? 'Session type is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('sessionTitleField'),
                controller: _titleController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Title is required.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('sessionLocationField'),
                controller: _locationController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const ValueKey('saveSessionButton'),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
