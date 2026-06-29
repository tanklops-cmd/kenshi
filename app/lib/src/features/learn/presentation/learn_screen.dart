import 'package:flutter/material.dart';
import 'package:kendo_companion/src/core/widgets/feature_placeholder.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Learn',
      prompt: 'What do I want to understand?',
      icon: Icons.menu_book,
    );
  }
}
