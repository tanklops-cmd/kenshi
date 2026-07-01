import 'package:kendo_companion/src/features/session/domain/session.dart';
import 'package:kendo_companion/src/features/session/domain/session_repository.dart';
import 'package:sqflite/sqflite.dart';

class SqliteSessionRepository implements SessionRepository {
  const SqliteSessionRepository(this._database);

  static const _tableName = 'sessions';

  final Database _database;

  @override
  Future<void> create(Session session) async {
    await _database.insert(
      _tableName,
      _toMap(session),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<Session?> read(String id) async {
    final rows = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return rows.isEmpty ? null : _fromMap(rows.single);
  }

  @override
  Future<List<Session>> readAll() async {
    final rows = await _database.query(
      _tableName,
      orderBy: 'training_date DESC, created_at DESC',
    );

    return rows.map(_fromMap).toList(growable: false);
  }

  @override
  Future<void> update(Session session) async {
    final updatedRows = await _database.update(
      _tableName,
      _toMap(session),
      where: 'id = ?',
      whereArgs: [session.id],
    );

    if (updatedRows != 1) {
      throw StateError('Session ${session.id} does not exist.');
    }
  }

  @override
  Future<void> delete(String id) async {
    await _database.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _toMap(Session session) {
    return {
      'id': session.id,
      'created_at': session.createdAt.toUtc().millisecondsSinceEpoch,
      'training_date': _dateToStorage(session.trainingDate),
      'session_type': session.sessionType.name,
      'title': session.title,
      'location': session.location,
      'notes': session.notes,
      'fresh_notes': session.freshNotes,
      'review_notes': session.reviewNotes,
      'next_focus': session.nextFocus,
      'first_capture_started_at': _dateTimeToStorage(
        session.firstCaptureStartedAt,
      ),
      'first_capture_completed_at': _dateTimeToStorage(
        session.firstCaptureCompletedAt,
      ),
      'review_started_at': _dateTimeToStorage(session.reviewStartedAt),
      'review_last_edited_at': _dateTimeToStorage(session.reviewLastEditedAt),
      'next_focus_created_at': _dateTimeToStorage(session.nextFocusCreatedAt),
      'updated_at': session.updatedAt.toUtc().millisecondsSinceEpoch,
    };
  }

  Session _fromMap(Map<String, Object?> row) {
    return Session(
      id: row['id']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row['created_at']! as int,
        isUtc: true,
      ),
      trainingDate: DateTime.parse(row['training_date']! as String),
      sessionType: SessionType.values.byName(row['session_type']! as String),
      title: row['title']! as String,
      location: row['location'] as String?,
      notes: row['notes'] as String?,
      freshNotes: row['fresh_notes'] as String?,
      reviewNotes: row['review_notes'] as String?,
      nextFocus: row['next_focus'] as String?,
      firstCaptureStartedAt: _dateTimeFromStorage(
        row['first_capture_started_at'] as int?,
      ),
      firstCaptureCompletedAt: _dateTimeFromStorage(
        row['first_capture_completed_at'] as int?,
      ),
      reviewStartedAt: _dateTimeFromStorage(row['review_started_at'] as int?),
      reviewLastEditedAt: _dateTimeFromStorage(
        row['review_last_edited_at'] as int?,
      ),
      nextFocusCreatedAt: _dateTimeFromStorage(
        row['next_focus_created_at'] as int?,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row['updated_at']! as int,
        isUtc: true,
      ),
    );
  }

  String _dateToStorage(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  int? _dateTimeToStorage(DateTime? dateTime) {
    return dateTime?.toUtc().millisecondsSinceEpoch;
  }

  DateTime? _dateTimeFromStorage(int? millisecondsSinceEpoch) {
    return millisecondsSinceEpoch == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            millisecondsSinceEpoch,
            isUtc: true,
          );
  }
}
