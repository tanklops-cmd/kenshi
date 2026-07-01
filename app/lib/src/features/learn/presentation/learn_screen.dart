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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final category = categories[index];

          return Card(
            child: ListTile(
              onTap: () =>
                  context.push(AppRoutes.learnCategoryLocation(category.name)),
              title: Text(category.label),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
