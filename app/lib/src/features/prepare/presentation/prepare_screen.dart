import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';

class PrepareScreen extends ConsumerWidget {
  const PrepareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Prepare')),
      body: sessions.when(
        data: (items) => _PrepareContent(sessions: items),
        error: (error, stackTrace) =>
            _PrepareError(onRetry: () => ref.invalidate(sessionsProvider)),
        loading: () => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _PrepareContent extends StatelessWidget {
  const _PrepareContent({required this.sessions});

  final List<Session> sessions;

  @override
  Widget build(BuildContext context) {
    final currentFocusSession = sessions.cast<Session?>().firstWhere(
      (session) => _hasText(session?.nextFocus),
      orElse: () => null,
    );
    final lastSession = sessions.firstOrNull;

    return ListView(
      key: const ValueKey('prepareList'),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        _SectionHeading(title: 'Current Focus'),
        const SizedBox(height: 10),
        _CurrentFocusCard(session: currentFocusSession),
        const SizedBox(height: 28),
        _SectionHeading(title: 'Last Session'),
        const SizedBox(height: 10),
        _LastSessionCard(session: lastSession),
        const SizedBox(height: 28),
        _SectionHeading(title: 'Upcoming Session'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.event_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  'Coming Soon',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrentFocusCard extends StatelessWidget {
  const _CurrentFocusCard({required this.session});

  final Session? session;

  @override
  Widget build(BuildContext context) {
    final source = session;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasFocus = source != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasFocus
                  ? source.nextFocus!.trim()
                  : 'No current focus.',
              style: hasFocus
                  ? textTheme.titleMedium
                  : textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
            ),
            const SizedBox(height: 14),
            FilledButton.tonal(
              key: const ValueKey('openFocusSessionButton'),
              onPressed: source == null
                  ? null
                  : () => context.push(
                      AppRoutes.sessionDetailLocation(source.id),
                    ),
              child: const Text('Open Session'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LastSessionCard extends StatelessWidget {
  const _LastSessionCard({required this.session});

  final Session? session;

  @override
  Widget build(BuildContext context) {
    final source = session;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (source == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No previous session.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'No review available.',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    final notes = _summaryNotes(source);
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(source.trainingDate);

    return Card(
      child: InkWell(
        key: const ValueKey('lastSessionCard'),
        onTap: () =>
            context.push(AppRoutes.sessionDetailLocation(source.id)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(source.title, style: textTheme.titleMedium),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: textTheme.bodySmall,
              ),
              if (notes != null) ...[
                const SizedBox(height: 10),
                Text(
                  notes,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
    );
  }
}

class _PrepareError extends StatelessWidget {
  const _PrepareError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Preparation could not be loaded.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

String? _summaryNotes(Session session) {
  if (_hasText(session.reviewNotes)) {
    return session.reviewNotes!.trim();
  }
  if (_hasText(session.freshNotes)) {
    return session.freshNotes!.trim();
  }
  return null;
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

