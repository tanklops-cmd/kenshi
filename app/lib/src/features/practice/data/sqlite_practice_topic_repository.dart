import 'package:kendo_companion/src/features/practice/domain/practice_topic.dart';
import 'package:kendo_companion/src/features/practice/domain/practice_topic_repository.dart';
import 'package:sqflite/sqflite.dart';

class SqlitePracticeTopicRepository implements PracticeTopicRepository {
  const SqlitePracticeTopicRepository(this._database);

  static const _tableName = 'practice_topics';

  final Database _database;

  @override
  Future<void> create(PracticeTopic topic) async {
    await _database.insert(
      _tableName,
      _toMap(topic),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<PracticeTopic?> read(String id) async {
    final rows = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return rows.isEmpty ? null : _fromMap(rows.single);
  }

  @override
  Future<List<PracticeTopic>> readAll({bool includeArchived = false}) async {
    final rows = await _database.query(
      _tableName,
      where: includeArchived ? null : 'archived = ?',
      whereArgs: includeArchived ? null : [0],
      orderBy: 'updated_at DESC, name COLLATE NOCASE ASC',
    );

    return rows.map(_fromMap).toList(growable: false);
  }

  @override
  Future<void> update(PracticeTopic topic) async {
    final updatedRows = await _database.update(
      _tableName,
      _toMap(topic),
      where: 'id = ?',
      whereArgs: [topic.id],
    );

    if (updatedRows != 1) {
      throw StateError('Practice topic ${topic.id} does not exist.');
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
      throw StateError('Practice topic $id does not exist.');
    }
  }

  Map<String, Object?> _toMap(PracticeTopic topic) {
    return {
      'id': topic.id,
      'created_at': topic.createdAt.toUtc().millisecondsSinceEpoch,
      'updated_at': topic.updatedAt.toUtc().millisecondsSinceEpoch,
      'category': topic.category.name,
      'name': topic.name,
      'current_state': topic.currentState,
      'mental_cues': topic.mentalCues,
      'archived': topic.archived ? 1 : 0,
    };
  }

  PracticeTopic _fromMap(Map<String, Object?> row) {
    return PracticeTopic(
      id: row['id']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row['created_at']! as int,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row['updated_at']! as int,
        isUtc: true,
      ),
      category: PracticeTopicCategory.values.byName(row['category']! as String),
      name: row['name']! as String,
      currentState: row['current_state']! as String,
      mentalCues: row['mental_cues']! as String,
      archived: (row['archived']! as int) == 1,
    );
  }
}
