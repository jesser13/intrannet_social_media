import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Function to initialize database for web platform
Future<Database> initializeDatabase(Function(Database, int) onCreate) async {
  // Initialize web database factory
  var factory = databaseFactoryFfiWeb;
  
  // Open database in memory for web
  return await factory.openDatabase(
    'flutter_intra.db',
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: onCreate,
    ),
  );
}
