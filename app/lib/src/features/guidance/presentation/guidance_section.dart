import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/features/guidance/application/guidance_providers.dart';
import 'package:kendo_companion/src/features/guidance/domain/guidance_entry.dart';

class GuidanceSection extends ConsumerWidget {
  const GuidanceSection({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(guidanceEntriesProvider(sessionId));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Guidance', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        entries.when(
          data: (items) =>
              _GuidanceList(sessionId: sessionId, entries: items),
          error: (_, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guidance could not be loaded.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(guidanceEntriesProvider(sessionId)),
                child: const Text('Try Again'),
              ),
            ],
          ),
          loading: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _GuidanceList extends StatelessWidget {
  const _GuidanceList({required this.sessionId, required this.entries});

  final String sessionId;
  final List<GuidanceEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              'No Guidance yet.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final entry in entries) ...[
            _GuidanceEntryCard(
              entry: entry,
              onTap: () => context.push(
                AppRoutes.guidanceDetailLocation(
                  sessionId: sessionId,
                  guidanceId: entry.id,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        FilledButton.tonalIcon(
          key: const ValueKey('addGuidanceButton'),
          onPressed: () =>
              context.push(AppRoutes.newGuidanceLocation(sessionId)),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Guidance'),
        ),
      ],
    );
  }
}

class _GuidanceEntryCard extends StatelessWidget {
  const _GuidanceEntryCard({
    required this.entry,
    required this.onTap,
  });

  final GuidanceEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(entry.createdAt.toLocal());

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.coachName case final name?) ...[
                Text(
                  name,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 5),
              ],
              Text(entry.advice, style: textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                date,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
