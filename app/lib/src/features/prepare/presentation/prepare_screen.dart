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
        loading: () => const Center(child: CircularProgressIndicator()),
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
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeading(title: 'Current Focus'),
        const SizedBox(height: 8),
        _CurrentFocusCard(session: currentFocusSession),
        const SizedBox(height: 24),
        _SectionHeading(title: 'Last Session'),
        const SizedBox(height: 8),
        _LastSessionCard(session: lastSession),
        const SizedBox(height: 24),
        _SectionHeading(title: 'Upcoming Session'),
        const SizedBox(height: 8),
        const Card(
          child: ListTile(
            leading: Icon(Icons.event_outlined),
            title: Text('Coming Soon'),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              source?.nextFocus?.trim() ?? 'No current focus.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
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
    if (source == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.history),
          title: Text('No previous session.'),
          subtitle: Text('No review available.'),
        ),
      );
    }

    final notes = _summaryNotes(source);
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(source.trainingDate);

    return Card(
      child: ListTile(
        key: const ValueKey('lastSessionCard'),
        onTap: () => context.push(AppRoutes.sessionDetailLocation(source.id)),
        leading: const Icon(Icons.history),
        title: Text(source.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(date),
            const SizedBox(height: 8),
            Text(
              notes ?? 'No review available.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _PrepareError extends StatelessWidget {
  const _PrepareError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Preparation could not be loaded.'),
            const SizedBox(height: 12),
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
