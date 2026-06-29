import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';

class ReflectScreen extends ConsumerWidget {
  const ReflectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: sessions.when(
        data: (items) => _SessionList(sessions: items),
        error: (error, stackTrace) =>
            _SessionListError(onRetry: () => ref.invalidate(sessionsProvider)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.newSession),
        icon: const Icon(Icons.add),
        label: const Text('New Session'),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.sessions});

  final List<Session> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No sessions yet.', textAlign: TextAlign.center),
        ),
      );
    }

    final localizations = MaterialLocalizations.of(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final session = sessions[index];
        final details = [
          session.sessionType.label,
          ?session.location,
        ].join(' · ');

        return Card(
          child: ListTile(
            onTap: () =>
                context.push(AppRoutes.sessionDetailLocation(session.id)),
            title: Text(session.title),
            subtitle: Text(details),
            trailing: Text(
              localizations.formatMediumDate(session.trainingDate),
            ),
          ),
        );
      },
    );
  }
}

class _SessionListError extends StatelessWidget {
  const _SessionListError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sessions could not be loaded.'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
