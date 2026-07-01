import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/core/database/app_database.dart';
import 'package:kendo_companion/src/features/guidance/data/sqlite_guidance_repository.dart';
import 'package:kendo_companion/src/features/guidance/domain/guidance_entry.dart';
import 'package:kendo_companion/src/features/guidance/domain/guidance_repository.dart';
import 'package:uuid/uuid.dart';

final guidanceRepositoryProvider = Provider<GuidanceRepository>((ref) {
  return SqliteGuidanceRepository(ref.watch(appDatabaseProvider));
});

final guidanceEntriesProvider = FutureProvider.autoDispose
    .family<List<GuidanceEntry>, String>((ref, sessionId) {
      return ref.watch(guidanceRepositoryProvider).readForSession(sessionId);
    });

final guidanceEntryProvider = FutureProvider.autoDispose
    .family<GuidanceEntry?, String>((ref, entryId) {
      return ref.watch(guidanceRepositoryProvider).read(entryId);
    });

final guidanceActionsProvider = Provider<GuidanceActions>(GuidanceActions.new);

class GuidanceActions {
  GuidanceActions(this._ref);

  static const _uuid = Uuid();
  final Ref _ref;

  Future<GuidanceEntry> create({
    required String sessionId,
    required String advice,
    String? coachName,
    String? context,
  }) async {
    final now = DateTime.now().toUtc();
    final entry = GuidanceEntry(
      id: _uuid.v4(),
      sessionId: sessionId,
      createdAt: now,
      updatedAt: now,
      coachName: _optionalText(coachName),
      advice: advice.trim(),
      context: _optionalText(context),
      archived: false,
    );
    await _ref.read(guidanceRepositoryProvider).create(entry);
    _ref.invalidate(guidanceEntriesProvider(sessionId));
    return entry;
  }

  Future<void> update(GuidanceEntry entry) async {
    final updated = entry.copyWith(
      coachName: _optionalText(entry.coachName),
      advice: entry.advice.trim(),
      context: _optionalText(entry.context),
      updatedAt: DateTime.now().toUtc(),
    );
    await _ref.read(guidanceRepositoryProvider).update(updated);
    _ref.invalidate(guidanceEntriesProvider(entry.sessionId));
  }

  Future<void> archive(GuidanceEntry entry) async {
    await _ref
        .read(guidanceRepositoryProvider)
        .archive(entry.id, updatedAt: DateTime.now().toUtc());
    _ref.invalidate(guidanceEntriesProvider(entry.sessionId));
    _ref.invalidate(guidanceEntryProvider(entry.id));
  }

  String? _optionalText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
