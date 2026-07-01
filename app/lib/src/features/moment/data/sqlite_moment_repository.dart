import 'package:kendo_companion/src/features/moment/domain/moment.dart';
import 'package:kendo_companion/src/features/moment/domain/moment_repository.dart';
import 'package:sqflite/sqflite.dart';

class SqliteMomentRepository implements MomentRepository {
  const SqliteMomentRepository(this._database);

  static const _tableName = 'moments';

  final Database _database;

  @override
  Future<void> create(Moment moment) async {
    await _database.insert(
      _tableName,
      _toMap(moment),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<Moment?> read(String id) async {
    final rows = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromMap(rows.single);
  }

  @override
  Future<List<Moment>> readForSession(
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
  Future<void> update(Moment moment) async {
    final updatedRows = await _database.update(
      _tableName,
      _toMap(moment),
      where: 'id = ?',
      whereArgs: [moment.id],
    );
    if (updatedRows != 1) {
      throw StateError('Moment ${moment.id} does not exist.');
    }
  }

  @override
  Future<void> archive(String id) async {
    final updatedRows = await _database.update(
      _tableName,
      {'archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (updatedRows != 1) {
      throw StateError('Moment $id does not exist.');
    }
  }

  Map<String, Object?> _toMap(Moment moment) {
    return {
      'id': moment.id,
      'session_id': moment.sessionId,
      'created_at': moment.createdAt.toUtc().millisecondsSinceEpoch,
      'type': moment.type.name,
      'local_path': moment.localPath,
      'title': moment.title,
      'note': moment.note,
      'archived': moment.archived ? 1 : 0,
    };
  }

  Moment _fromMap(Map<String, Object?> row) {
    return Moment(
      id: row['id']! as String,
      sessionId: row['session_id']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row['created_at']! as int,
        isUtc: true,
      ),
      type: MomentType.values.byName(row['type']! as String),
      localPath: row['local_path']! as String,
      title: row['title']! as String,
      note: row['note']! as String,
      archived: (row['archived']! as int) == 1,
    );
  }
}
