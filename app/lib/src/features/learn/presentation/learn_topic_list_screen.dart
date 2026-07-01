import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/features/learn/application/learn_providers.dart';
import 'package:kendo_companion/src/features/learn/domain/learn_topic.dart';

class LearnTopicListScreen extends ConsumerWidget {
  const LearnTopicListScreen({required this.category, super.key});

  final LearnCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref
        .watch(learnRepositoryProvider)
        .topicsForCategory(category);

    return Scaffold(
      appBar: AppBar(title: Text(category.label)),
      body: topics.isEmpty
          ? const Center(child: Text('No topics in this category yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: topics.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final topic = topics[index];

                return Card(
                  child: ListTile(
                    onTap: () => context.push(
                      AppRoutes.learnTopicDetailLocation(topic.id),
                    ),
                    title: Text(topic.title),
                    subtitle: Text(topic.summary),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
    );
  }
}
