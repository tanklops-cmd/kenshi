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
          ? Center(
              child: Text(
                'Topic not found.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
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
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        Text(topic.title, style: textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          topic.category.label,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 20),
        Text(topic.summary, style: textTheme.titleMedium),
        const SizedBox(height: 16),
        Text(topic.body, style: textTheme.bodyLarge),
        if (topic.relatedPracticeTopicName case final relatedTopic?) ...[
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Related Practice Topic',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(relatedTopic, style: textTheme.titleMedium),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
