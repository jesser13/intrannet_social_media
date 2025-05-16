import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Function to initialize database for native platforms
Future<Database> initializeDatabase(Function(Database, int) onCreate) async {
  // Initialize FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  String path = join(await getDatabasesPath(), 'flutter_intra.db');
  return await openDatabase(
    path,
    version: 1,
    onCreate: onCreate,
  );
}
