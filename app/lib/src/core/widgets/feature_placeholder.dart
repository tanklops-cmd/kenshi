import 'package:flutter/material.dart';

class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    required this.title,
    required this.prompt,
    required this.icon,
    super.key,
  });

  final String title;
  final String prompt;
  // Accepted for API compatibility; not rendered — the peaceful layout
  // avoids generic icon treatments in favour of typographic calm.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thin gold accent line — a quiet mark of quality.
              SizedBox(
                width: 36,
                child: Divider(
                  color: colorScheme.primary.withAlpha(170),
                  thickness: 0.75,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                prompt,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.75,
                  letterSpacing: 0.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

