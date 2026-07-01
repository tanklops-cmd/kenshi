import 'package:kendo_companion/src/features/guidance/domain/guidance_entry.dart';
import 'package:kendo_companion/src/features/guidance/domain/guidance_repository.dart';

class FakeGuidanceRepository implements GuidanceRepository {
  final List<GuidanceEntry> _entries = [];

  @override
  Future<void> create(GuidanceEntry entry) async {
    if (entry.advice.trim().isEmpty) {
      throw ArgumentError.value(entry.advice, 'advice');
    }
    _entries.add(entry);
  }

  @override
  Future<GuidanceEntry?> read(String id) async {
    for (final entry in _entries) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<List<GuidanceEntry>> readForSession(
    String sessionId, {
    bool includeArchived = false,
  }) async {
    final result = _entries.where(
      (entry) =>
          entry.sessionId == sessionId && (includeArchived || !entry.archived),
    );
    return result.toList()
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
  }

  @override
  Future<void> update(GuidanceEntry entry) async {
    if (entry.advice.trim().isEmpty) {
      throw ArgumentError.value(entry.advice, 'advice');
    }
    final index = _entries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      throw StateError('Guidance entry ${entry.id} does not exist.');
    }
    _entries[index] = entry;
  }

  @override
  Future<void> archive(String id, {required DateTime updatedAt}) async {
    final index = _entries.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw StateError('Guidance entry $id does not exist.');
    }
    _entries[index] = _entries[index].copyWith(
      archived: true,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<List<GuidanceEntry>> readRecent(int limit) async {
    final sorted = _entries
        .where((entry) => !entry.archived)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }
}
