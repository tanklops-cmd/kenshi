import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/features/practice/application/practice_topic_providers.dart';
import 'package:kendo_companion/src/features/practice/domain/practice_topic.dart';

class NewPracticeTopicScreen extends ConsumerStatefulWidget {
  const NewPracticeTopicScreen({super.key});

  @override
  ConsumerState<NewPracticeTopicScreen> createState() =>
      _NewPracticeTopicScreenState();
}

class _NewPracticeTopicScreenState
    extends ConsumerState<NewPracticeTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  PracticeTopicCategory? _category;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isCreating = true);

    try {
      final topic = await ref
          .read(practiceTopicsProvider.notifier)
          .createTopic(name: _nameController.text, category: _category!);

      if (mounted) {
        context.replace(AppRoutes.practiceTopicDetailLocation(topic.id));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Practice topic could not be created.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Practice Topic')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                key: const ValueKey('practiceTopicNameField'),
                controller: _nameController,
                enabled: !_isCreating,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Name is required.'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PracticeTopicCategory>(
                key: const ValueKey('practiceTopicCategoryField'),
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: PracticeTopicCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isCreating
                    ? null
                    : (value) => setState(() => _category = value),
                validator: (value) =>
                    value == null ? 'Category is required.' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const ValueKey('createPracticeTopicButton'),
                onPressed: _isCreating ? null : _create,
                child: _isCreating
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Topic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
