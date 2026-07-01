import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

const _databaseFileName = 'kendo_companion.sqlite3';
const appDatabaseSchemaVersion = 4;

final appDatabaseProvider = Provider<sqflite.Database>((ref) {
  throw StateError('The application database has not been initialised.');
});

Future<sqflite.Database> openAppDatabase() async {
  final supportDirectory = await getApplicationSupportDirectory();
  final databasePath = path.join(supportDirectory.path, _databaseFileName);

  if (Platform.isWindows) {
    sqflite_ffi.sqfliteFfiInit();
    return openAppDatabaseAtPath(
      databaseFactory: sqflite_ffi.databaseFactoryFfi,
      databasePath: databasePath,
    );
  }

  return openAppDatabaseAtPath(
    databaseFactory: sqflite.databaseFactorySqflitePlugin,
    databasePath: databasePath,
  );
}

Future<sqflite.Database> openAppDatabaseAtPath({
  required sqflite.DatabaseFactory databaseFactory,
  required String databasePath,
}) {
  return databaseFactory.openDatabase(
    databasePath,
    options: sqflite.OpenDatabaseOptions(
      version: appDatabaseSchemaVersion,
      onCreate: (database, version) =>
          _migrateDatabase(database, oldVersion: 0, newVersion: version),
      onUpgrade: (database, oldVersion, newVersion) => _migrateDatabase(
        database,
        oldVersion: oldVersion,
        newVersion: newVersion,
      ),
    ),
  );
}

Future<void> _migrateDatabase(
  sqflite.Database database, {
  required int oldVersion,
  required int newVersion,
}) async {
  if (oldVersion < 1 && newVersion >= 1) {
    await database.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY NOT NULL,
        created_at INTEGER NOT NULL,
        training_date TEXT NOT NULL,
        session_type TEXT NOT NULL CHECK (
          session_type IN (
            'clubKeiko',
            'seminar',
            'shiai',
            'grading',
            'homeTraining',
            'other'
          )
        ),
        title TEXT NOT NULL CHECK (length(trim(title)) > 0),
        location TEXT,
        notes TEXT,
        updated_at INTEGER NOT NULL
      )
    ''');
    await database.execute('''
      CREATE INDEX index_sessions_training_date
      ON sessions (training_date DESC, created_at DESC)
    ''');
  }

  if (oldVersion < 2 && newVersion >= 2) {
    await database.execute('ALTER TABLE sessions ADD COLUMN fresh_notes TEXT');
    await database.execute('ALTER TABLE sessions ADD COLUMN review_notes TEXT');
    await database.execute('ALTER TABLE sessions ADD COLUMN next_focus TEXT');
  }

  if (oldVersion < 3 && newVersion >= 3) {
    await database.execute(
      'ALTER TABLE sessions ADD COLUMN first_capture_started_at INTEGER',
    );
    await database.execute(
      'ALTER TABLE sessions ADD COLUMN first_capture_completed_at INTEGER',
    );
    await database.execute(
      'ALTER TABLE sessions ADD COLUMN review_started_at INTEGER',
    );
    await database.execute(
      'ALTER TABLE sessions ADD COLUMN review_last_edited_at INTEGER',
    );
    await database.execute(
      'ALTER TABLE sessions ADD COLUMN next_focus_created_at INTEGER',
    );
  }

  if (oldVersion < 4 && newVersion >= 4) {
    await database.execute('''
      CREATE TABLE practice_topics (
        id TEXT PRIMARY KEY NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        category TEXT NOT NULL CHECK (
          category IN (
            'fundamentals',
            'shikakeWaza',
            'ojiWaza',
            'hikiWaza',
            'tsuki',
            'footwork',
            'kamae',
            'kihon',
            'other'
          )
        ),
        name TEXT NOT NULL CHECK (length(trim(name)) > 0),
        current_state TEXT NOT NULL DEFAULT '',
        mental_cues TEXT NOT NULL DEFAULT '',
        archived INTEGER NOT NULL DEFAULT 0 CHECK (archived IN (0, 1))
      )
    ''');
    await database.execute('''
      CREATE INDEX index_practice_topics_active
      ON practice_topics (archived, updated_at DESC)
    ''');
  }
}
