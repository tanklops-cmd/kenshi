import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/widgets/autosave_text_field.dart';
import 'package:kendo_companion/src/features/moment/application/moment_providers.dart';
import 'package:kendo_companion/src/features/moment/domain/moment.dart';
import 'package:kendo_companion/src/features/moment/presentation/moment_thumbnail.dart';

class MomentDetailScreen extends ConsumerWidget {
  const MomentDetailScreen({required this.momentId, super.key});

  final String momentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moment = ref.watch(momentProvider(momentId));
    return Scaffold(
      appBar: AppBar(title: const Text('Moment')),
      body: moment.when(
        data: (value) => value == null
            ? const Center(child: Text('Moment not found.'))
            : _MomentDetail(moment: value),
        error: (error, stackTrace) =>
            const Center(child: Text('Moment could not be loaded.')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _MomentDetail extends ConsumerStatefulWidget {
  const _MomentDetail({required this.moment});

  final Moment moment;

  @override
  ConsumerState<_MomentDetail> createState() => _MomentDetailState();
}

class _MomentDetailState extends ConsumerState<_MomentDetail> {
  late Moment _moment;
  Future<void> _saveQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _moment = widget.moment;
  }

  Future<void> _queueUpdate(Moment Function(Moment current) update) {
    final result = Completer<void>();
    _saveQueue = _saveQueue.then((_) async {
      try {
        final updated = update(_moment);
        await ref.read(momentActionsProvider).update(updated);
        _moment = updated;
        result.complete();
      } on Object catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        MomentThumbnail(moment: _moment),
        const SizedBox(height: 20),
        AutosaveTextField(
          fieldKey: const ValueKey('momentTitleField'),
          initialValue: _moment.title,
          singleLine: true,
          hintText: 'Title',
          onSave: (edit) => _queueUpdate(
            (current) => current.copyWith(title: edit.value.trim()),
          ),
        ),
        const SizedBox(height: 20),
        AutosaveTextField(
          fieldKey: const ValueKey('momentNoteField'),
          initialValue: _moment.note,
          hintText: 'What does this Moment show?',
          onSave: (edit) =>
              _queueUpdate((current) => current.copyWith(note: edit.value)),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          key: const ValueKey('deleteMomentButton'),
          onPressed: _deleteMoment,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete Moment'),
        ),
      ],
    );
  }

  Future<void> _deleteMoment() async {
    FocusScope.of(context).unfocus();
    final choice = await showDialog<_DeleteChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Moment?'),
        content: const Text(
          'The Moment will be removed from this Session. '
          'Would you also like to delete the local file?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _DeleteChoice.keepFile),
            child: const Text('Keep File'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _DeleteChoice.deleteFile),
            child: const Text('Delete File'),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) {
      return;
    }
    await ref
        .read(momentActionsProvider)
        .archive(_moment, deleteFile: choice == _DeleteChoice.deleteFile);
    if (mounted) {
      context.pop();
    }
  }
}

enum _DeleteChoice { keepFile, deleteFile }
