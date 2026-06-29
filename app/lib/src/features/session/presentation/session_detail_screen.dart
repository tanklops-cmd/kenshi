import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider(sessionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Session')),
      body: session.when(
        data: (value) => value == null
            ? const Center(child: Text('Session not found.'))
            : _SessionDetails(session: value),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Session could not be loaded.'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(sessionProvider(sessionId)),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SessionDetails extends StatelessWidget {
  const _SessionDetails({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(session.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        _DetailRow(
          icon: Icons.calendar_today,
          label: 'Training Date',
          value: localizations.formatMediumDate(session.trainingDate),
        ),
        _DetailRow(
          icon: Icons.sports_martial_arts,
          label: 'Session Type',
          value: session.sessionType.label,
        ),
        if (session.location case final location?)
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: location,
          ),
        const SizedBox(height: 24),
        for (final section in const [
          'Reflection',
          'Guidance',
          'Moments',
          'Next Intention',
        ])
          Card(
            child: ListTile(
              title: Text(section),
              subtitle: const Text('Coming Soon'),
            ),
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
