import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/core/database/app_database.dart';
import 'package:kendo_companion/src/features/moment/data/moment_media_services.dart';
import 'package:kendo_companion/src/features/moment/data/sqlite_moment_repository.dart';
import 'package:kendo_companion/src/features/moment/domain/moment.dart';
import 'package:kendo_companion/src/features/moment/domain/moment_repository.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

final momentRepositoryProvider = Provider<MomentRepository>((ref) {
  return SqliteMomentRepository(ref.watch(appDatabaseProvider));
});

final momentMediaPickerProvider = Provider<MomentMediaPicker>((ref) {
  return const FilePickerMomentMediaPicker();
});

final momentFileStoreProvider = Provider<MomentFileStore>((ref) {
  return const LocalMomentFileStore();
});

final momentsProvider = FutureProvider.autoDispose.family<List<Moment>, String>(
  (ref, sessionId) {
    return ref.watch(momentRepositoryProvider).readForSession(sessionId);
  },
);

final momentProvider = FutureProvider.autoDispose.family<Moment?, String>((
  ref,
  momentId,
) {
  return ref.watch(momentRepositoryProvider).read(momentId);
});

final momentActionsProvider = Provider<MomentActions>(MomentActions.new);

class MomentActions {
  MomentActions(this._ref);

  static const _uuid = Uuid();
  final Ref _ref;

  Future<Moment?> pickAndCreate({
    required String sessionId,
    required MomentType type,
  }) async {
    final localPath = await _ref.read(momentMediaPickerProvider).pick(type);
    if (localPath == null) {
      return null;
    }

    final moment = Moment(
      id: _uuid.v4(),
      sessionId: sessionId,
      createdAt: DateTime.now().toUtc(),
      type: type,
      localPath: localPath,
      title: path.basenameWithoutExtension(localPath),
      note: '',
      archived: false,
    );
    await _ref.read(momentRepositoryProvider).create(moment);
    _ref.invalidate(momentsProvider(sessionId));
    return moment;
  }

  Future<void> update(Moment moment) async {
    await _ref.read(momentRepositoryProvider).update(moment);
    _ref.invalidate(momentsProvider(moment.sessionId));
  }

  Future<void> archive(Moment moment, {required bool deleteFile}) async {
    await _ref.read(momentRepositoryProvider).archive(moment.id);
    if (deleteFile) {
      await _ref.read(momentFileStoreProvider).delete(moment.localPath);
    }
    _ref.invalidate(momentProvider(moment.id));
    _ref.invalidate(momentsProvider(moment.sessionId));
  }
}
