import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/core/widgets/autosave_text_field.dart';
import 'package:kendo_companion/src/features/moment/presentation/moments_section.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';
import 'package:kendo_companion/src/features/session/domain/session_review_updates.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider(sessionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Session')),
      body: session.when(
        data: (value) => value == null
            ? const Center(child: Text('Session not found.'))
            : _SessionWorkspace(session: value),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Session could not be loaded.'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(sessionProvider(sessionId)),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SessionWorkspace extends ConsumerStatefulWidget {
  const _SessionWorkspace({required this.session});

  final Session session;

  @override
  ConsumerState<_SessionWorkspace> createState() => _SessionWorkspaceState();
}

class _SessionWorkspaceState extends ConsumerState<_SessionWorkspace> {
  late Session _session;
  Future<void> _saveQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  @override
  void didUpdateWidget(_SessionWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.id != widget.session.id) {
      _session = widget.session;
    }
  }

  Future<void> _queueUpdate(Session Function(Session current) update) {
    final result = Completer<void>();
    final repository = ref.read(sessionRepositoryProvider);

    _saveQueue = _saveQueue.then((_) async {
      try {
        final updatedSession = update(
          _session,
        ).copyWith(updatedAt: DateTime.now().toUtc());
        await repository.update(updatedSession);
        _session = updatedSession;
        if (mounted) {
          setState(() {});
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
    final localizations = MaterialLocalizations.of(context);
    final stage = _SessionStage.from(_session);

    return ListView(
      key: const ValueKey('sessionWorkspaceList'),
      padding: const EdgeInsets.all(24),
      children: [
        Text(_session.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        _DetailRow(
          icon: Icons.calendar_today,
          label: 'Training Date',
          value: localizations.formatMediumDate(_session.trainingDate),
        ),
        _DetailRow(
          icon: Icons.sports_martial_arts,
          label: 'Session Type',
          value: _session.sessionType.label,
        ),
        if (_session.location case final location?)
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: location,
          ),
        const SizedBox(height: 24),
        if (stage == _SessionStage.freshCapture)
          _FreshNotesSection(
            initialValue: _session.freshNotes,
            shouldRecordCompletion:
                _session.firstCaptureStartedAt != null &&
                _session.firstCaptureCompletedAt == null,
            onSave: (edit) => _queueUpdate(
              (current) => SessionReviewUpdates.freshNotesChanged(
                current,
                freshNotes: _capturedText(edit.value),
                startedAt: edit.startedAt,
              ),
            ),
            onCompleted: (completedAt) => _queueUpdate(
              (current) => SessionReviewUpdates.freshNotesCompleted(
                current,
                completedAt: completedAt,
              ),
            ),
          )
        else ...[
          _CompletedNotesCard(
            cardKey: const ValueKey('freshNotesCompletedCard'),
            title: "What's on your mind?",
            value: _session.freshNotes ?? 'No original thoughts captured.',
          ),
          const SizedBox(height: 12),
          _ReviewNotesSection(
            initialValue: _session.reviewNotes,
            onSave: (edit) => _queueUpdate(
              (current) => SessionReviewUpdates.reviewNotesChanged(
                current,
                reviewNotes: _capturedText(edit.value),
                startedAt: edit.startedAt,
                lastEditedAt: edit.lastEditedAt,
              ),
            ),
          ),
          if (stage.index >= _SessionStage.nextFocus.index) ...[
            const SizedBox(height: 12),
            _NextFocusSection(
              initialValue: _session.nextFocus,
              onSave: (edit) => _queueUpdate(
                (current) => SessionReviewUpdates.nextFocusChanged(
                  current,
                  nextFocus: _optionalText(edit.value),
                  createdAt: edit.lastEditedAt,
                ),
              ),
            ),
          ],
          if (stage == _SessionStage.summary) ...[
            const SizedBox(height: 12),
            const _ComingSoonSection(title: 'Guidance'),
            const SizedBox(height: 8),
            MomentsSection(sessionId: _session.id),
          ],
        ],
      ],
    );
  }

  String? _optionalText(String value) {
    final trimmedValue = value.trim();
    return trimmedValue.isEmpty ? null : trimmedValue;
  }

  String? _capturedText(String value) {
    return value.trim().isEmpty ? null : value;
  }
}

class _FreshNotesSection extends StatefulWidget {
  const _FreshNotesSection({
    required this.initialValue,
    required this.shouldRecordCompletion,
    required this.onSave,
    required this.onCompleted,
  });

  final String? initialValue;
  final bool shouldRecordCompletion;
  final Future<void> Function(AutosaveEdit edit) onSave;
  final Future<void> Function(DateTime completedAt) onCompleted;

  @override
  State<_FreshNotesSection> createState() => _FreshNotesSectionState();
}

class _FreshNotesSectionState extends State<_FreshNotesSection> {
  late bool _isReadOnly;

  @override
  void initState() {
    super.initState();
    _isReadOnly = widget.initialValue != null;
    if (_isReadOnly && widget.shouldRecordCompletion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_recordCompletionQuietly());
      });
    }
  }

  Future<void> _completeCapture(String value) async {
    if (_isReadOnly || value.trim().isEmpty) {
      return;
    }

    try {
      await _recordCompletion();
      if (mounted) {
        setState(() => _isReadOnly = true);
      }
    } on Object {
      // Keep the field editable so completion can be retried quietly.
    }
  }

  Future<void> _recordCompletion() {
    return widget.onCompleted(DateTime.now().toUtc());
  }

  Future<void> _recordCompletionQuietly() async {
    try {
      await _recordCompletion();
    } on Object {
      // A later visit can retry without interrupting the user.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What's on your mind?",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            AutosaveTextField(
              fieldKey: const ValueKey('freshNotesField'),
              initialValue: widget.initialValue ?? '',
              autofocus: !_isReadOnly,
              readOnly: _isReadOnly,
              dismissOnTapOutside: true,
              hintText: "What stood out from today's training?",
              onSave: widget.onSave,
              onFocusLost: (value) {
                unawaited(_completeCapture(value));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewNotesSection extends StatefulWidget {
  const _ReviewNotesSection({required this.initialValue, required this.onSave});

  final String? initialValue;
  final Future<void> Function(AutosaveEdit edit) onSave;

  @override
  State<_ReviewNotesSection> createState() => _ReviewNotesSectionState();
}

class _ReviewNotesSectionState extends State<_ReviewNotesSection> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    if (!_isOpen) {
      return Card(
        child: ListTile(
          key: const ValueKey('reviewNotesSection'),
          title: const Text('Take another look'),
          subtitle: Text(widget.initialValue ?? 'Not started'),
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() => _isOpen = true);
          },
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Take another look',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            AutosaveTextField(
              fieldKey: const ValueKey('reviewNotesField'),
              initialValue: widget.initialValue ?? '',
              hintText: 'What has changed in your understanding?',
              onSave: widget.onSave,
            ),
          ],
        ),
      ),
    );
  }
}

class _NextFocusSection extends StatefulWidget {
  const _NextFocusSection({required this.initialValue, required this.onSave});

  final String? initialValue;
  final Future<void> Function(AutosaveEdit edit) onSave;

  @override
  State<_NextFocusSection> createState() => _NextFocusSectionState();
}

class _NextFocusSectionState extends State<_NextFocusSection> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    if (!_isEditing) {
      return Card(
        child: ListTile(
          key: const ValueKey('nextFocusSection'),
          title: const Text('Next Focus'),
          subtitle: Text(widget.initialValue ?? 'Not set'),
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() => _isEditing = true);
          },
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Next Focus', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            AutosaveTextField(
              fieldKey: const ValueKey('nextFocusField'),
              initialValue: widget.initialValue ?? '',
              singleLine: true,
              autofocus: true,
              hintText: 'One short sentence',
              onSave: widget.onSave,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonSection extends StatelessWidget {
  const _ComingSoonSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(title), subtitle: const Text('Coming Soon')),
    );
  }
}

class _CompletedNotesCard extends StatelessWidget {
  const _CompletedNotesCard({
    required this.cardKey,
    required this.title,
    required this.value,
  });

  final Key cardKey;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: cardKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(value),
          ],
        ),
      ),
    );
  }
}

enum _SessionStage {
  freshCapture,
  review,
  nextFocus,
  summary;

  factory _SessionStage.from(Session session) {
    if (_hasText(session.nextFocus)) {
      return summary;
    }
    if (_hasText(session.reviewNotes)) {
      return nextFocus;
    }
    if (_hasText(session.freshNotes)) {
      if (session.firstCaptureStartedAt != null &&
          session.firstCaptureCompletedAt == null) {
        return freshCapture;
      }
      return review;
    }
    return freshCapture;
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
