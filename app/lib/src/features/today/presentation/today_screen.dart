import 'package:flutter/material.dart';
import 'package:kendo_companion/src/core/widgets/feature_placeholder.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Today',
      prompt: 'Where am I in my current training cycle?',
      icon: Icons.today,
    );
  }
}
