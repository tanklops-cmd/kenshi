import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

const _databaseFileName = 'kendo_companion.sqlite3';

final appDatabaseProvider = Provider<sqflite.Database>((ref) {
  throw StateError('The application database has not been initialised.');
});

Future<sqflite.Database> openAppDatabase() async {
  final supportDirectory = await getApplicationSupportDirectory();
  final databasePath = path.join(supportDirectory.path, _databaseFileName);

  if (Platform.isWindows) {
    sqflite_ffi.sqfliteFfiInit();
    return sqflite_ffi.databaseFactoryFfi.openDatabase(databasePath);
  }

  return sqflite.databaseFactorySqflitePlugin.openDatabase(databasePath);
}
