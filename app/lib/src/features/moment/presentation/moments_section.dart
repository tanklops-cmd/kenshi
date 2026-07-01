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
            const SizedBox(height: 10),
            moments.when(
              data: (items) =>
                  _MomentList(sessionId: sessionId, moments: items),
              error: (error, stackTrace) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moments could not be loaded.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(momentsProvider(sessionId)),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
              loading: () => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (moments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              'No Moments yet.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          )
        else
          for (final moment in moments) ...[
            InkWell(
              onTap: () => context.push(
                AppRoutes.momentDetailLocation(
                  sessionId: sessionId,
                  momentId: moment.id,
                ),
              ),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      moment.type == MomentType.photo
                          ? Icons.image_outlined
                          : Icons.videocam_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        moment.title.trim().isEmpty
                            ? moment.type.label
                            : moment.title,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
          ],
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          key: const ValueKey('addMomentButton'),
          onPressed: () => _showMomentTypePicker(context, ref),
          icon: const Icon(Icons.add, size: 18),
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
