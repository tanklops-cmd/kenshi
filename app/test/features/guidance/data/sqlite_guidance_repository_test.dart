import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/core/database/app_database.dart';
import 'package:kendo_companion/src/features/guidance/data/sqlite_guidance_repository.dart';
import 'package:kendo_companion/src/features/guidance/domain/guidance_entry.dart';
import 'package:kendo_companion/src/features/session/data/sqlite_session_repository.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/test_database.dart';

void main() {
  late Database database;
  late SqliteGuidanceRepository repository;

  setUp(() async {
    database = await openTestDatabase();
    await SqliteSessionRepository(database).create(_session());
    repository = SqliteGuidanceRepository(database);
  });

  tearDown(() => database.close());

  test('creates and reads Guidance for its Session', () async {
    final entry = _entry();
    await repository.create(entry);

    _expectEntry((await repository.read(entry.id))!, entry);
    expect(await repository.readForSession('session-1'), hasLength(1));
    expect(await repository.readForSession('another-session'), isEmpty);
  });

  test('requires non-empty Advice', () async {
    expect(
      () => repository.create(_entry().copyWith(advice: '  ')),
      throwsArgumentError,
    );
  });

  test('updates Guidance metadata', () async {
    final entry = _entry();
    await repository.create(entry);
    final updated = entry.copyWith(
      coachName: 'Sensei',
      advice: 'Keep the left hand centred.',
      context: 'After kirikaeshi.',
      updatedAt: DateTime.utc(2026, 7, 2, 10),
    );

    await repository.update(updated);

    _expectEntry((await repository.read(entry.id))!, updated);
  });

  test('archives without permanently deleting Guidance', () async {
    final entry = _entry();
    final archivedAt = DateTime.utc(2026, 7, 3, 9);
    await repository.create(entry);

    await repository.archive(entry.id, updatedAt: archivedAt);

    expect(await repository.readForSession(entry.sessionId), isEmpty);
    final all = await repository.readForSession(
      entry.sessionId,
      includeArchived: true,
    );
    expect(all.single.archived, isTrue);
    expect(all.single.updatedAt, archivedAt);
  });

  test('migrates version 6 databases without changing Sessions', () async {
    sqfliteFfiInit();
    final directory = await Directory.systemTemp.createTemp(
      'kendo_companion_guidance_migration_test_',
    );
    final databasePath = path.join(directory.path, 'app.sqlite3');

    try {
      final versionSix = await databaseFactoryFfi.openDatabase(databasePath);
      await versionSix.execute('''
        CREATE TABLE sessions (
          id TEXT PRIMARY KEY NOT NULL,
          title TEXT NOT NULL
        )
      ''');
      await versionSix.insert('sessions', {
        'id': 'existing-session',
        'title': 'Existing Session',
      });
      await versionSix.setVersion(6);
      await versionSix.close();

      final migrated = await openAppDatabaseAtPath(
        databaseFactory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      expect(await migrated.getVersion(), appDatabaseSchemaVersion);
      final columns = await migrated.rawQuery(
        'PRAGMA table_info(guidance_entries)',
      );
      expect(
        columns.map((column) => column['name']),
        containsAll([
          'id',
          'session_id',
          'created_at',
          'updated_at',
          'coach_name',
          'advice',
          'context',
          'archived',
        ]),
      );
      expect(
        (await migrated.query('sessions')).single['title'],
        'Existing Session',
      );
      await migrated.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });
}

Session _session() {
  return Session(
    id: 'session-1',
    createdAt: DateTime.utc(2026, 7, 1, 9),
    trainingDate: DateTime(2026, 7, 1),
    sessionType: SessionType.clubKeiko,
    title: 'Wednesday keiko',
    updatedAt: DateTime.utc(2026, 7, 1, 9),
  );
}

GuidanceEntry _entry() {
  return GuidanceEntry(
    id: 'guidance-1',
    sessionId: 'session-1',
    createdAt: DateTime.utc(2026, 7, 1, 10),
    updatedAt: DateTime.utc(2026, 7, 1, 10),
    coachName: 'Senpai',
    advice: 'Relax the right hand.',
    context: 'After the final drill.',
    archived: false,
  );
}

void _expectEntry(GuidanceEntry actual, GuidanceEntry expected) {
  expect(actual.id, expected.id);
  expect(actual.sessionId, expected.sessionId);
  expect(actual.createdAt, expected.createdAt);
  expect(actual.updatedAt, expected.updatedAt);
  expect(actual.coachName, expected.coachName);
  expect(actual.advice, expected.advice);
  expect(actual.context, expected.context);
  expect(actual.archived, expected.archived);
}
