import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/core/database/app_database.dart';
import 'package:kendo_companion/src/features/moment/data/sqlite_moment_repository.dart';
import 'package:kendo_companion/src/features/moment/domain/moment.dart';
import 'package:kendo_companion/src/features/session/data/sqlite_session_repository.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/test_database.dart';

void main() {
  late Database database;
  late SqliteMomentRepository repository;

  setUp(() async {
    database = await openTestDatabase();
    await SqliteSessionRepository(database).create(_session());
    repository = SqliteMomentRepository(database);
  });

  tearDown(() => database.close());

  test('creates and reads a Moment for its Session', () async {
    final moment = _moment();
    await repository.create(moment);

    final stored = await repository.read(moment.id);
    expect(stored, isNotNull);
    _expectMoment(stored!, moment);
    expect(await repository.readForSession('session-1'), hasLength(1));
    expect(await repository.readForSession('another-session'), isEmpty);
  });

  test('updates Moment metadata', () async {
    final moment = _moment();
    await repository.create(moment);
    final updated = moment.copyWith(
      title: 'Successful debana-men',
      note: 'I moved as the intention appeared.',
    );

    await repository.update(updated);

    _expectMoment((await repository.read(moment.id))!, updated);
  });

  test('archives without deleting the Moment record', () async {
    final moment = _moment();
    await repository.create(moment);

    await repository.archive(moment.id);

    expect(await repository.readForSession(moment.sessionId), isEmpty);
    final all = await repository.readForSession(
      moment.sessionId,
      includeArchived: true,
    );
    expect(all, hasLength(1));
    expect(all.single.archived, isTrue);
  });

  test(
    'migrates a version 4 database without changing existing Sessions',
    () async {
      sqfliteFfiInit();
      final directory = await Directory.systemTemp.createTemp(
        'kendo_companion_moment_migration_test_',
      );
      final databasePath = path.join(directory.path, 'app.sqlite3');

      try {
        final versionFour = await databaseFactoryFfi.openDatabase(databasePath);
        await versionFour.execute('''
        CREATE TABLE sessions (
          id TEXT PRIMARY KEY NOT NULL,
          title TEXT NOT NULL
        )
      ''');
        await versionFour.insert('sessions', {
          'id': 'existing-session',
          'title': 'Existing Session',
        });
        await versionFour.setVersion(4);
        await versionFour.close();

        final migrated = await openAppDatabaseAtPath(
          databaseFactory: databaseFactoryFfi,
          databasePath: databasePath,
        );
        expect(await migrated.getVersion(), appDatabaseSchemaVersion);
        final columns = await migrated.rawQuery('PRAGMA table_info(moments)');
        expect(
          columns.map((column) => column['name']),
          containsAll([
            'id',
            'session_id',
            'created_at',
            'type',
            'local_path',
            'title',
            'note',
            'archived',
          ]),
        );
        final sessions = await migrated.query('sessions');
        expect(sessions.single['title'], 'Existing Session');
        await migrated.close();
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
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

Moment _moment() {
  return Moment(
    id: 'moment-1',
    sessionId: 'session-1',
    createdAt: DateTime.utc(2026, 7, 1, 10),
    type: MomentType.video,
    localPath: r'C:\media\debana-men.mp4',
    title: 'Debana-men timing',
    note: '',
    archived: false,
  );
}

void _expectMoment(Moment actual, Moment expected) {
  expect(actual.id, expected.id);
  expect(actual.sessionId, expected.sessionId);
  expect(actual.createdAt, expected.createdAt);
  expect(actual.type, expected.type);
  expect(actual.localPath, expected.localPath);
  expect(actual.title, expected.title);
  expect(actual.note, expected.note);
  expect(actual.archived, expected.archived);
}
