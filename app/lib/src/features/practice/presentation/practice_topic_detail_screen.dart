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
            ? const Center(child: Text('Practice topic not found.'))
            : _PracticeTopicWorkspace(topic: value),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Practice topic could not be loaded.'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(practiceTopicProvider(topicId)),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(_topic.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          _topic.category.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Text('Current State', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        AutosaveTextField(
          fieldKey: const ValueKey('practiceCurrentStateField'),
          initialValue: _topic.currentState,
          hintText: 'What is your current understanding of this topic?',
          onSave: (edit) => _queueUpdate(
            (current) => current.copyWith(currentState: edit.value),
          ),
        ),
        const SizedBox(height: 24),
        Text('Mental Cues', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
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
