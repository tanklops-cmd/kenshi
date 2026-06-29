import 'package:flutter/material.dart';
import 'package:kendo_companion/src/core/widgets/feature_placeholder.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Practice',
      prompt: 'What am I working on?',
      icon: Icons.fitness_center,
    );
  }
}
