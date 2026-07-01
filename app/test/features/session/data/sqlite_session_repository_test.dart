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
      freshNotes: 'My timing felt late.',
      reviewNotes: 'I was reacting instead of initiating.',
      nextFocus: 'Win centre before attacking.',
      firstCaptureStartedAt: DateTime.utc(2026, 6, 1, 9, 30),
      firstCaptureCompletedAt: DateTime.utc(2026, 6, 1, 9, 35),
      reviewStartedAt: DateTime.utc(2026, 6, 2, 8),
      reviewLastEditedAt: DateTime.utc(2026, 6, 2, 8, 15),
      nextFocusCreatedAt: DateTime.utc(2026, 6, 2, 8, 20),
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
    'migrates an existing unversioned database to the current schema',
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
        final columns = await migratedDatabase.rawQuery(
          'PRAGMA table_info(sessions)',
        );
        expect(
          columns.map((column) => column['name']),
          containsAll([
            'fresh_notes',
            'review_notes',
            'next_focus',
            'first_capture_started_at',
            'first_capture_completed_at',
            'review_started_at',
            'review_last_edited_at',
            'next_focus_created_at',
          ]),
        );
        await migratedDatabase.close();
      } finally {
        await temporaryDirectory.delete(recursive: true);
      }
    },
  );

  test('migrates version 1 sessions without losing data', () async {
    sqfliteFfiInit();
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'kendo_companion_v1_migration_test_',
    );
    final databasePath = path.join(temporaryDirectory.path, 'app.sqlite3');

    try {
      final versionOneDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
      );
      await versionOneDatabase.execute('''
        CREATE TABLE sessions (
          id TEXT PRIMARY KEY NOT NULL,
          created_at INTEGER NOT NULL,
          training_date TEXT NOT NULL,
          session_type TEXT NOT NULL,
          title TEXT NOT NULL,
          location TEXT,
          notes TEXT,
          updated_at INTEGER NOT NULL
        )
      ''');
      await versionOneDatabase.insert('sessions', {
        'id': 'existing-session',
        'created_at': DateTime.utc(2026, 6, 1, 9).millisecondsSinceEpoch,
        'training_date': '2026-06-01',
        'session_type': SessionType.clubKeiko.name,
        'title': 'Existing keiko',
        'location': 'Central Dojo',
        'notes': null,
        'updated_at': DateTime.utc(2026, 6, 1, 9).millisecondsSinceEpoch,
      });
      await versionOneDatabase.setVersion(1);
      await versionOneDatabase.close();

      final migratedDatabase = await openAppDatabaseAtPath(
        databaseFactory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      final migratedRepository = SqliteSessionRepository(migratedDatabase);
      final session = await migratedRepository.read('existing-session');

      expect(await migratedDatabase.getVersion(), appDatabaseSchemaVersion);
      expect(session, isNotNull);
      expect(session!.title, 'Existing keiko');
      expect(session.location, 'Central Dojo');
      expect(session.freshNotes, isNull);
      expect(session.reviewNotes, isNull);
      expect(session.nextFocus, isNull);
      expect(session.firstCaptureStartedAt, isNull);
      expect(session.firstCaptureCompletedAt, isNull);
      expect(session.reviewStartedAt, isNull);
      expect(session.reviewLastEditedAt, isNull);
      expect(session.nextFocusCreatedAt, isNull);
      await migratedDatabase.close();
    } finally {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('migrates version 2 review data without losing it', () async {
    sqfliteFfiInit();
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'kendo_companion_v2_migration_test_',
    );
    final databasePath = path.join(temporaryDirectory.path, 'app.sqlite3');

    try {
      final versionTwoDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
      );
      await versionTwoDatabase.execute('''
        CREATE TABLE sessions (
          id TEXT PRIMARY KEY NOT NULL,
          created_at INTEGER NOT NULL,
          training_date TEXT NOT NULL,
          session_type TEXT NOT NULL,
          title TEXT NOT NULL,
          location TEXT,
          notes TEXT,
          updated_at INTEGER NOT NULL,
          fresh_notes TEXT,
          review_notes TEXT,
          next_focus TEXT
        )
      ''');
      await versionTwoDatabase.insert('sessions', {
        'id': 'review-session',
        'created_at': DateTime.utc(2026, 6, 1, 9).millisecondsSinceEpoch,
        'training_date': '2026-06-01',
        'session_type': SessionType.clubKeiko.name,
        'title': 'Review keiko',
        'location': null,
        'notes': null,
        'updated_at': DateTime.utc(2026, 6, 2, 9).millisecondsSinceEpoch,
        'fresh_notes': 'Original thought',
        'review_notes': 'Later understanding',
        'next_focus': 'Win centre.',
      });
      await versionTwoDatabase.setVersion(2);
      await versionTwoDatabase.close();

      final migratedDatabase = await openAppDatabaseAtPath(
        databaseFactory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      final migratedRepository = SqliteSessionRepository(migratedDatabase);
      final session = await migratedRepository.read('review-session');

      expect(await migratedDatabase.getVersion(), appDatabaseSchemaVersion);
      expect(session, isNotNull);
      expect(session!.freshNotes, 'Original thought');
      expect(session.reviewNotes, 'Later understanding');
      expect(session.nextFocus, 'Win centre.');
      expect(session.firstCaptureStartedAt, isNull);
      expect(session.firstCaptureCompletedAt, isNull);
      expect(session.reviewStartedAt, isNull);
      expect(session.reviewLastEditedAt, isNull);
      expect(session.nextFocusCreatedAt, isNull);
      await migratedDatabase.close();
    } finally {
      await temporaryDirectory.delete(recursive: true);
    }
  });
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
  expect(actual.freshNotes, expected.freshNotes);
  expect(actual.reviewNotes, expected.reviewNotes);
  expect(actual.nextFocus, expected.nextFocus);
  expect(actual.firstCaptureStartedAt, expected.firstCaptureStartedAt);
  expect(actual.firstCaptureCompletedAt, expected.firstCaptureCompletedAt);
  expect(actual.reviewStartedAt, expected.reviewStartedAt);
  expect(actual.reviewLastEditedAt, expected.reviewLastEditedAt);
  expect(actual.nextFocusCreatedAt, expected.nextFocusCreatedAt);
  expect(actual.updatedAt, expected.updatedAt);
}
