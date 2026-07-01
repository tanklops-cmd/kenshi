import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/features/moment/application/moment_providers.dart';
import 'package:kendo_companion/src/features/moment/domain/moment.dart';

class MomentsSection extends ConsumerWidget {
  const MomentsSection({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider(sessionId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Moments', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            moments.when(
              data: (items) =>
                  _MomentList(sessionId: sessionId, moments: items),
              error: (error, stackTrace) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Moments could not be loaded.'),
                  TextButton(
                    onPressed: () => ref.invalidate(momentsProvider(sessionId)),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentList extends ConsumerWidget {
  const _MomentList({required this.sessionId, required this.moments});

  final String sessionId;
  final List<Moment> moments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (moments.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('No Moments yet.'),
          )
        else
          for (final moment in moments)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                moment.type == MomentType.photo
                    ? Icons.image_outlined
                    : Icons.videocam_outlined,
              ),
              title: Text(
                moment.title.trim().isEmpty ? moment.type.label : moment.title,
              ),
              subtitle: Text(moment.type.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(
                AppRoutes.momentDetailLocation(
                  sessionId: sessionId,
                  momentId: moment.id,
                ),
              ),
            ),
        FilledButton.tonalIcon(
          key: const ValueKey('addMomentButton'),
          onPressed: () => _showMomentTypePicker(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Moment'),
        ),
      ],
    );
  }

  Future<void> _showMomentTypePicker(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final type = await showModalBottomSheet<MomentType>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Pick Photo'),
              onTap: () => Navigator.pop(context, MomentType.photo),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Pick Video'),
              onTap: () => Navigator.pop(context, MomentType.video),
            ),
          ],
        ),
      ),
    );
    if (type == null || !context.mounted) {
      return;
    }

    try {
      if (type == MomentType.video) {
        final sourcePath = await ref
            .read(momentActionsProvider)
            .pickMedia(type);
        if (sourcePath != null && context.mounted) {
          await context.push(
            AppRoutes.momentVideoPreviewLocation(sessionId),
            extra: sourcePath,
          );
        }
      } else {
        final moment = await ref
            .read(momentActionsProvider)
            .pickAndCreate(sessionId: sessionId, type: type);
        if (moment != null && context.mounted) {
          await context.push(
            AppRoutes.momentDetailLocation(
              sessionId: sessionId,
              momentId: moment.id,
            ),
          );
        }
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Moment could not be added.')),
        );
      }
    }
  }
}
