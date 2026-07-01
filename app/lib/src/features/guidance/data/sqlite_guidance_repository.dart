import 'package:kendo_companion/src/features/guidance/domain/guidance_entry.dart';
import 'package:kendo_companion/src/features/guidance/domain/guidance_repository.dart';
import 'package:sqflite/sqflite.dart';

class SqliteGuidanceRepository implements GuidanceRepository {
  const SqliteGuidanceRepository(this._database);

  static const _tableName = 'guidance_entries';

  final Database _database;

  @override
  Future<void> create(GuidanceEntry entry) async {
    _validate(entry);
    await _database.insert(
      _tableName,
      _toMap(entry),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<GuidanceEntry?> read(String id) async {
    final rows = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromMap(rows.single);
  }

  @override
  Future<List<GuidanceEntry>> readForSession(
    String sessionId, {
    bool includeArchived = false,
  }) async {
    final rows = await _database.query(
      _tableName,
      where: includeArchived
          ? 'session_id = ?'
          : 'session_id = ? AND archived = ?',
      whereArgs: includeArchived ? [sessionId] : [sessionId, 0],
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromMap).toList(growable: false);
  }

  @override
  Future<void> update(GuidanceEntry entry) async {
    _validate(entry);
    final updatedRows = await _database.update(
      _tableName,
      _toMap(entry),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
    if (updatedRows != 1) {
      throw StateError('Guidance entry ${entry.id} does not exist.');
    }
  }

  @override
  Future<void> archive(String id, {required DateTime updatedAt}) async {
    final updatedRows = await _database.update(
      _tableName,
      {'archived': 1, 'updated_at': updatedAt.toUtc().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (updatedRows != 1) {
      throw StateError('Guidance entry $id does not exist.');
    }
  }

  @override
  Future<List<GuidanceEntry>> readRecent(int limit) async {
    final rows = await _database.query(
      _tableName,
      where: 'archived = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(_fromMap).toList(growable: false);
  }

  void _validate(GuidanceEntry entry) {
    if (entry.advice.trim().isEmpty) {
      throw ArgumentError.value(entry.advice, 'advice', 'Advice is required.');
    }
  }

  Map<String, Object?> _toMap(GuidanceEntry entry) {
    return {
      'id': entry.id,
      'session_id': entry.sessionId,
      'created_at': entry.createdAt.toUtc().millisecondsSinceEpoch,
      'updated_at': entry.updatedAt.toUtc().millisecondsSinceEpoch,
      'coach_name': entry.coachName,
      'advice': entry.advice,
      'context': entry.context,
      'archived': entry.archived ? 1 : 0,
    };
  }

  GuidanceEntry _fromMap(Map<String, Object?> row) {
    return GuidanceEntry(
      id: row['id']! as String,
      sessionId: row['session_id']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row['created_at']! as int,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row['updated_at']! as int,
        isUtc: true,
      ),
      coachName: row['coach_name'] as String?,
      advice: row['advice']! as String,
      context: row['context'] as String?,
      archived: (row['archived']! as int) == 1,
    );
  }
}
