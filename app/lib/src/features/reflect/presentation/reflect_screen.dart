import 'package:flutter/material.dart';
import 'package:kendo_companion/src/core/widgets/feature_placeholder.dart';

class ReflectScreen extends StatelessWidget {
  const ReflectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Reflect',
      prompt: 'What did I learn from training?',
      icon: Icons.edit_note,
    );
  }
}
