import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/core/database/app_database.dart';
import 'package:kendo_companion/src/features/practice/data/sqlite_practice_topic_repository.dart';
import 'package:kendo_companion/src/features/practice/domain/practice_topic.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/test_database.dart';

void main() {
  late Database database;
  late SqlitePracticeTopicRepository repository;

  setUp(() async {
    database = await openTestDatabase();
    repository = SqlitePracticeTopicRepository(database);
  });

  tearDown(() => database.close());

  test('creates and reads a practice topic', () async {
    final topic = _topic();

    await repository.create(topic);

    final stored = await repository.read(topic.id);
    expect(stored, isNotNull);
    _expectTopic(stored!, topic);
  });

  test('updates a practice topic', () async {
    final original = _topic();
    final updated = original.copyWith(
      category: PracticeTopicCategory.shikakeWaza,
      name: 'Debana-men',
      currentState: 'Create the opportunity rather than waiting.',
      mentalCues: 'Win centre first.\nCommit forward.',
      updatedAt: DateTime.utc(2026, 7, 2, 10),
    );
    await repository.create(original);

    await repository.update(updated);

    final stored = await repository.read(original.id);
    expect(stored, isNotNull);
    _expectTopic(stored!, updated);
  });

  test('archives without permanently deleting a practice topic', () async {
    final topic = _topic();
    final archivedAt = DateTime.utc(2026, 7, 3, 9);
    await repository.create(topic);

    await repository.archive(topic.id, updatedAt: archivedAt);

    expect(await repository.readAll(), isEmpty);
    final allTopics = await repository.readAll(includeArchived: true);
    expect(allTopics, hasLength(1));
    expect(allTopics.single.archived, isTrue);
    expect(allTopics.single.updatedAt, archivedAt);
    expect(await repository.read(topic.id), isNotNull);
  });

  test('migrates version 3 databases and persists practice topics', () async {
    sqfliteFfiInit();
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'kendo_companion_practice_migration_test_',
    );
    final databasePath = path.join(temporaryDirectory.path, 'app.sqlite3');

    try {
      final versionThreeDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
      );
      await versionThreeDatabase.setVersion(3);
      await versionThreeDatabase.close();

      var migratedDatabase = await openAppDatabaseAtPath(
        databaseFactory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      expect(await migratedDatabase.getVersion(), appDatabaseSchemaVersion);
      final columns = await migratedDatabase.rawQuery(
        'PRAGMA table_info(practice_topics)',
      );
      expect(
        columns.map((column) => column['name']),
        containsAll([
          'id',
          'created_at',
          'updated_at',
          'category',
          'name',
          'current_state',
          'mental_cues',
          'archived',
        ]),
      );
      await SqlitePracticeTopicRepository(migratedDatabase).create(_topic());
      await migratedDatabase.close();

      migratedDatabase = await openAppDatabaseAtPath(
        databaseFactory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      final persisted = await SqlitePracticeTopicRepository(
        migratedDatabase,
      ).read('topic-1');
      expect(persisted, isNotNull);
      expect(persisted!.name, 'Seme');
      await migratedDatabase.close();
    } finally {
      await temporaryDirectory.delete(recursive: true);
    }
  });
}

PracticeTopic _topic() {
  return PracticeTopic(
    id: 'topic-1',
    createdAt: DateTime.utc(2026, 7, 1, 9),
    updatedAt: DateTime.utc(2026, 7, 1, 9),
    category: PracticeTopicCategory.fundamentals,
    name: 'Seme',
    currentState: '',
    mentalCues: '',
    archived: false,
  );
}

void _expectTopic(PracticeTopic actual, PracticeTopic expected) {
  expect(actual.id, expected.id);
  expect(actual.createdAt, expected.createdAt);
  expect(actual.updatedAt, expected.updatedAt);
  expect(actual.category, expected.category);
  expect(actual.name, expected.name);
  expect(actual.currentState, expected.currentState);
  expect(actual.mentalCues, expected.mentalCues);
  expect(actual.archived, expected.archived);
}
