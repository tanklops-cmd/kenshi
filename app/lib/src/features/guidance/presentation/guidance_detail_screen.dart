import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/widgets/autosave_text_field.dart';
import 'package:kendo_companion/src/features/guidance/application/guidance_providers.dart';
import 'package:kendo_companion/src/features/guidance/domain/guidance_entry.dart';

class GuidanceDetailScreen extends ConsumerWidget {
  const GuidanceDetailScreen({
    required this.sessionId,
    this.guidanceId,
    super.key,
  });

  final String sessionId;
  final String? guidanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryId = guidanceId;
    if (entryId == null) {
      return GuidanceEditor(sessionId: sessionId);
    }

    final entry = ref.watch(guidanceEntryProvider(entryId));
    return entry.when(
      data: (value) => value == null
          ? const Scaffold(body: Center(child: Text('Guidance not found.')))
          : GuidanceEditor(sessionId: sessionId, initialEntry: value),
      error: (error, stackTrace) => const Scaffold(
        body: Center(child: Text('Guidance could not be loaded.')),
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class GuidanceEditor extends ConsumerStatefulWidget {
  const GuidanceEditor({required this.sessionId, this.initialEntry, super.key});

  final String sessionId;
  final GuidanceEntry? initialEntry;

  @override
  ConsumerState<GuidanceEditor> createState() => _GuidanceEditorState();
}

class _GuidanceEditorState extends ConsumerState<GuidanceEditor> {
  late GuidanceEntry? _entry;
  late String _coachName;
  late String _advice;
  late String _context;
  Future<void> _saveQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _entry = widget.initialEntry;
    _coachName = _entry?.coachName ?? '';
    _advice = _entry?.advice ?? '';
    _context = _entry?.context ?? '';
  }

  Future<void> _saveDraft({
    String? coachName,
    String? advice,
    String? context,
  }) {
    if (coachName != null) {
      _coachName = coachName;
    }
    if (advice != null) {
      _advice = advice;
    }
    if (context != null) {
      _context = context;
    }

    final result = Completer<void>();
    _saveQueue = _saveQueue.then((_) async {
      try {
        if (_entry == null) {
          if (_advice.trim().isEmpty) {
            result.complete();
            return;
          }
          _entry = await ref
              .read(guidanceActionsProvider)
              .create(
                sessionId: widget.sessionId,
                coachName: _coachName,
                advice: _advice,
                context: _context,
              );
          if (mounted) {
            setState(() {});
          }
        } else {
          final updated = _entry!.copyWith(
            coachName: _optionalText(_coachName),
            advice: _advice,
            context: _optionalText(_context),
          );
          await ref.read(guidanceActionsProvider).update(updated);
          _entry = updated;
        }
        result.complete();
      } on Object catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(entry == null ? 'Add Guidance' : 'Guidance')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
        children: [
          // Advice — the heart of the entry, shown first and prominently.
          AutosaveTextField(
            fieldKey: const ValueKey('guidanceAdviceField'),
            initialValue: _advice,
            autofocus: entry == null,
            hintText: 'What were you taught?',
            onSave: (edit) => _saveDraft(advice: edit.value),
          ),
          const SizedBox(height: 24),
          // Coach — supporting context, secondary.
          AutosaveTextField(
            fieldKey: const ValueKey('guidanceCoachField'),
            initialValue: _coachName,
            singleLine: true,
            hintText: 'Who taught you this?  (optional)',
            onSave: (edit) => _saveDraft(coachName: edit.value),
          ),
          const SizedBox(height: 16),
          // Context — when or why.
          AutosaveTextField(
            fieldKey: const ValueKey('guidanceContextField'),
            initialValue: _context,
            hintText: 'When or why was this advice given?  (optional)',
            onSave: (edit) => _saveDraft(context: edit.value),
          ),
          if (entry != null) ...[
            const SizedBox(height: 28),
            Text(
              'Created ${MaterialLocalizations.of(context).formatMediumDate(entry.createdAt.toLocal())}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              key: const ValueKey('archiveGuidanceButton'),
              onPressed: _archive,
              icon: const Icon(Icons.archive_outlined, size: 18),
              label: const Text('Archive'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _archive() async {
    final entry = _entry;
    if (entry == null) {
      return;
    }
    FocusScope.of(context).unfocus();
    await _saveQueue;
    await ref.read(guidanceActionsProvider).archive(entry);
    if (mounted) {
      context.pop();
    }
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
