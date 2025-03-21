import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        noteId TEXT,
        note TEXT,
        isSynced INTEGER
      )
    ''');
  }

  // Insert a note into the local database
  Future<void> insertNote(String userId, String noteId, String note, bool isSynced) async {
    final db = await database;
    await db.insert(
      'notes',
      {
        'userId': userId,
        'noteId': noteId,
        'note': note,
        'isSynced': isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update an existing note in the local database
  Future<void> updateNote(String userId, String noteId, String note, bool isSynced) async {
    final db = await database;
    await db.update(
      'notes',
      {
        'note': note,
        'isSynced': isSynced ? 1 : 0,
      },
      where: 'userId = ? AND noteId = ?',
      whereArgs: [userId, noteId],
    );
  }

  // Fetch all notes for a user from the local database
  Future<List<Map<String, dynamic>>> getNotes(String userId) async {
    final db = await database;
    return await db.query(
      'notes',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Update the sync status of a note
  Future<void> updateSyncStatus(String noteId, bool isSynced) async {
    final db = await database;
    await db.update(
      'notes',
      {'isSynced': isSynced ? 1 : 0},
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
  }

  // Fetch all unsynced notes
  Future<List<Map<String, dynamic>>> getUnsyncedNotes() async {
    final db = await database;
    return await db.query(
      'notes',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
  }

  // Check if a note already exists in the local database
  Future<bool> noteExists(String userId, String noteId) async {
    final db = await database;
    var result = await db.query(
      'notes',
      where: 'userId = ? AND noteId = ?',
      whereArgs: [userId, noteId],
    );
    return result.isNotEmpty;
  }
}