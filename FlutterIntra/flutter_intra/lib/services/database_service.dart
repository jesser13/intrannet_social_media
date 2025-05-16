import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditionally import FFI
import 'database_service_native.dart' if (dart.library.html) 'database_service_web.dart' as db_impl;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize database based on platform
    return await db_impl.initializeDatabase(_createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT,
        profilePicture TEXT,
        jobTitle TEXT,
        bio TEXT,
        role TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    // Groups table
    await db.execute('''
      CREATE TABLE groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        image TEXT,
        isPrivate INTEGER NOT NULL,
        creatorId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (creatorId) REFERENCES users (id)
      )
    ''');

    // Group members table
    await db.execute('''
      CREATE TABLE group_members(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        role TEXT NOT NULL,
        joinedAt TEXT NOT NULL,
        FOREIGN KEY (groupId) REFERENCES groups (id),
        FOREIGN KEY (userId) REFERENCES users (id),
        UNIQUE(groupId, userId)
      )
    ''');

    // Posts table
    await db.execute('''
      CREATE TABLE posts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        groupId INTEGER,
        content TEXT NOT NULL,
        attachments TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        likesCount INTEGER DEFAULT 0,
        commentsCount INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (groupId) REFERENCES groups (id)
      )
    ''');

    // Comments table
    await db.execute('''
      CREATE TABLE comments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (postId) REFERENCES posts (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Likes table
    await db.execute('''
      CREATE TABLE likes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (postId) REFERENCES posts (id),
        FOREIGN KEY (userId) REFERENCES users (id),
        UNIQUE(postId, userId)
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        senderId INTEGER NOT NULL,
        receiverId INTEGER NOT NULL,
        isGroupMessage INTEGER NOT NULL,
        content TEXT NOT NULL,
        attachments TEXT,
        isRead INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (senderId) REFERENCES users (id)
      )
    ''');
  }
}