import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/features/learn/application/learn_providers.dart';
import 'package:kendo_companion/src/features/learn/domain/learn_topic.dart';

class LearnTopicDetailScreen extends ConsumerWidget {
  const LearnTopicDetailScreen({required this.topicId, super.key});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topic = ref.watch(learnRepositoryProvider).topicById(topicId);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn Topic')),
      body: topic == null
          ? const Center(child: Text('Learn topic not found.'))
          : _TopicDetails(topic: topic),
    );
  }
}

class _TopicDetails extends StatelessWidget {
  const _TopicDetails({required this.topic});

  final LearnTopic topic;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(topic.title, style: textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(topic.category.label, style: textTheme.labelLarge),
        const SizedBox(height: 20),
        Text(topic.summary, style: textTheme.titleMedium),
        const SizedBox(height: 16),
        Text(topic.body, style: textTheme.bodyLarge),
        if (topic.relatedPracticeTopicName case final relatedTopic?) ...[
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              title: const Text('Related Practice Topic'),
              subtitle: Text(relatedTopic),
            ),
          ),
        ],
      ],
    );
  }
}
