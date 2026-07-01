import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/core/widgets/autosave_text_field.dart';
import 'package:kendo_companion/src/features/practice/application/practice_topic_providers.dart';
import 'package:kendo_companion/src/features/practice/domain/practice_topic.dart';

class PracticeTopicDetailScreen extends ConsumerWidget {
  const PracticeTopicDetailScreen({required this.topicId, super.key});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topic = ref.watch(practiceTopicProvider(topicId));

    return Scaffold(
      appBar: AppBar(title: const Text('Practice Topic')),
      body: topic.when(
        data: (value) => value == null
            ? Center(
                child: Text(
                  'Practice topic not found.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              )
            : _PracticeTopicWorkspace(topic: value),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Practice topic could not be loaded.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(practiceTopicProvider(topicId)),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _PracticeTopicWorkspace extends ConsumerStatefulWidget {
  const _PracticeTopicWorkspace({required this.topic});

  final PracticeTopic topic;

  @override
  ConsumerState<_PracticeTopicWorkspace> createState() =>
      _PracticeTopicWorkspaceState();
}

class _PracticeTopicWorkspaceState
    extends ConsumerState<_PracticeTopicWorkspace> {
  late PracticeTopic _topic;
  Future<void> _saveQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _topic = widget.topic;
  }

  Future<void> _queueUpdate(
    PracticeTopic Function(PracticeTopic current) update,
  ) {
    final result = Completer<void>();
    final repository = ref.read(practiceTopicRepositoryProvider);

    _saveQueue = _saveQueue.then((_) async {
      try {
        final updatedTopic = update(
          _topic,
        ).copyWith(updatedAt: DateTime.now().toUtc());
        await repository.update(updatedTopic);
        _topic = updatedTopic;
        if (mounted) {
          ref.invalidate(practiceTopicsProvider);
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        Text(_topic.name, style: textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          _topic.category.label,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 28),
        Text('Current State', style: textTheme.titleLarge),
        const SizedBox(height: 10),
        AutosaveTextField(
          fieldKey: const ValueKey('practiceCurrentStateField'),
          initialValue: _topic.currentState,
          hintText: 'What is your current understanding of this topic?',
          onSave: (edit) => _queueUpdate(
            (current) => current.copyWith(currentState: edit.value),
          ),
        ),
        const SizedBox(height: 28),
        Text('Mental Cues', style: textTheme.titleLarge),
        const SizedBox(height: 10),
        AutosaveTextField(
          fieldKey: const ValueKey('practiceMentalCuesField'),
          initialValue: _topic.mentalCues,
          hintText:
              'Short reminders you want to remember during keiko.\n\n'
              'Win centre first.\n'
              'Relax the right hand.\n'
              'Finish every strike forward.',
          onSave: (edit) => _queueUpdate(
            (current) => current.copyWith(mentalCues: edit.value),
          ),
        ),
      ],
    );
  }
}
