import 'package:kendo_companion/src/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> openTestDatabase() {
  sqfliteFfiInit();
  return openAppDatabaseAtPath(
    databaseFactory: databaseFactoryFfi,
    databasePath: inMemoryDatabasePath,
  );
}
