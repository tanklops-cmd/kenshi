import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/core/database/app_database.dart';
import 'package:kendo_companion/src/features/session/data/sqlite_session_repository.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/test_database.dart';

void main() {
  late Database database;
  late SqliteSessionRepository repository;

  setUp(() async {
    database = await openTestDatabase();
    repository = SqliteSessionRepository(database);
  });

  tearDown(() => database.close());

  test('creates and reads a session', () async {
    final session = _session();

    await repository.create(session);

    final stored = await repository.read(session.id);
    expect(stored, isNotNull);
    _expectSession(stored!, session);
  });

  test('reads sessions in descending training date order', () async {
    final older = _session(id: 'older', trainingDate: DateTime(2026, 5, 1));
    final newer = _session(id: 'newer', trainingDate: DateTime(2026, 6, 1));
    await repository.create(older);
    await repository.create(newer);

    final sessions = await repository.readAll();

    expect(sessions.map((session) => session.id), ['newer', 'older']);
  });

  test('updates a session', () async {
    final original = _session();
    final updated = original.copyWith(
      sessionType: SessionType.seminar,
      title: 'Regional seminar',
      location: 'Central Dojo',
      notes: 'Bring two shinai',
      updatedAt: DateTime.utc(2026, 6, 2, 10),
    );
    await repository.create(original);

    await repository.update(updated);

    final stored = await repository.read(original.id);
    expect(stored, isNotNull);
    _expectSession(stored!, updated);
  });

  test('deletes a session', () async {
    final session = _session();
    await repository.create(session);

    await repository.delete(session.id);

    expect(await repository.read(session.id), isNull);
  });

  test(
    'migrates an existing unversioned database to schema version 1',
    () async {
      sqfliteFfiInit();
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'kendo_companion_migration_test_',
      );
      final databasePath = path.join(temporaryDirectory.path, 'app.sqlite3');

      try {
        final unversionedDatabase = await databaseFactoryFfi.openDatabase(
          databasePath,
        );
        expect(await unversionedDatabase.getVersion(), 0);
        await unversionedDatabase.close();

        final migratedDatabase = await openAppDatabaseAtPath(
          databaseFactory: databaseFactoryFfi,
          databasePath: databasePath,
        );
        expect(await migratedDatabase.getVersion(), appDatabaseSchemaVersion);
        final tables = await migratedDatabase.query(
          'sqlite_master',
          columns: ['name'],
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'sessions'],
        );
        expect(tables, hasLength(1));
        await migratedDatabase.close();
      } finally {
        await temporaryDirectory.delete(recursive: true);
      }
    },
  );
}

Session _session({String id = 'session-1', DateTime? trainingDate}) {
  return Session(
    id: id,
    createdAt: DateTime.utc(2026, 6, 1, 9),
    trainingDate: trainingDate ?? DateTime(2026, 6, 1),
    sessionType: SessionType.clubKeiko,
    title: 'Tuesday keiko',
    updatedAt: DateTime.utc(2026, 6, 1, 9),
  );
}

void _expectSession(Session actual, Session expected) {
  expect(actual.id, expected.id);
  expect(actual.createdAt, expected.createdAt);
  expect(actual.trainingDate, expected.trainingDate);
  expect(actual.sessionType, expected.sessionType);
  expect(actual.title, expected.title);
  expect(actual.location, expected.location);
  expect(actual.notes, expected.notes);
  expect(actual.updatedAt, expected.updatedAt);
}
