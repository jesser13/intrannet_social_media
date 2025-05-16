import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'enterprise_social.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        role TEXT,
        photo TEXT,
        function TEXT,
        bio TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        userId TEXT,
        content TEXT,
        imagePath TEXT,
        filePath TEXT,
        groupId TEXT,
        createdAt TEXT,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (groupId) REFERENCES groups(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE comments (
        id TEXT PRIMARY KEY,
        postId TEXT,
        userId TEXT,
        content TEXT,
        createdAt TEXT,
        FOREIGN KEY (postId) REFERENCES posts(id),
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE likes (
        id TEXT PRIMARY KEY,
        postId TEXT,
        userId TEXT,
        FOREIGN KEY (postId) REFERENCES posts(id),
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE groups (
        id TEXT PRIMARY KEY,
        name TEXT,
        isPrivate INTEGER,
        creatorId TEXT,
        FOREIGN KEY (creatorId) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE group_members (
        groupId TEXT,
        userId TEXT,
        FOREIGN KEY (groupId) REFERENCES groups(id),
        FOREIGN KEY (userId) REFERENCES users(id),
        PRIMARY KEY (groupId, userId)
      )
    ''');
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        senderId TEXT,
        receiverId TEXT,
        content TEXT,
        createdAt TEXT,
        FOREIGN KEY (senderId) REFERENCES users(id),
        FOREIGN KEY (receiverId) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        userId TEXT,
        content TEXT,
        type TEXT,
        relatedId TEXT,
        createdAt TEXT,
        isRead INTEGER,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');
  }
}