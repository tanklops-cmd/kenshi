import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/features/practice/application/practice_topic_providers.dart';
import 'package:kendo_companion/src/features/practice/domain/practice_topic.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(practiceTopicsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: topics.when(
        data: (items) => _PracticeTopicList(topics: items),
        error: (error, stackTrace) => _PracticeTopicListError(
          onRetry: () => ref.invalidate(practiceTopicsProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.newPracticeTopic),
        icon: const Icon(Icons.add),
        label: const Text('New Practice Topic'),
      ),
    );
  }
}

class _PracticeTopicList extends StatelessWidget {
  const _PracticeTopicList({required this.topics});

  final List<PracticeTopic> topics;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return const Center(child: Text('No practice topics yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: topics.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final topic = topics[index];
        final firstLine = topic.currentState.split(RegExp(r'\r?\n')).first;

        return Card(
          child: ListTile(
            onTap: () =>
                context.push(AppRoutes.practiceTopicDetailLocation(topic.id)),
            title: Text(topic.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic.category.label),
                Text(
                  firstLine.trim().isEmpty
                      ? 'Current state not set'
                      : firstLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PracticeTopicListError extends StatelessWidget {
  const _PracticeTopicListError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Practice topics could not be loaded.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}
