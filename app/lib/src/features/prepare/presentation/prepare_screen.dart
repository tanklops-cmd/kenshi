import 'package:flutter/material.dart';
import 'package:kendo_companion/src/core/widgets/feature_placeholder.dart';

class PrepareScreen extends StatelessWidget {
  const PrepareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Prepare',
      prompt: 'What should I remember before the next keiko?',
      icon: Icons.self_improvement,
    );
  }
}
