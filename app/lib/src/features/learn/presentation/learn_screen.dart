import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/features/learn/application/learn_providers.dart';
import 'package:kendo_companion/src/features/search/presentation/search_button.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(learnRepositoryProvider).categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        actions: const [SearchButton()],
      ),
      body: ListView.separated(
        key: const ValueKey('learnCategoryList'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final count = ref
              .watch(learnRepositoryProvider)
              .topicsForCategory(category)
              .length;

          return Card(
            child: InkWell(
              onTap: () =>
                  context.push(AppRoutes.learnCategoryLocation(category.name)),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '$count',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
