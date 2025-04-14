import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:unicap_cg/models/fav_caption.dart';

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
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 2, // Incremented version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create notes table
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT ,
        noteId TEXT ,
        noteName TEXT ,
        note TEXT ,
        isSynced INTEGER ,
        createdAt TEXT 
      )
    ''');

    // Create favorite_captions table
    await db.execute('''
      CREATE TABLE favorite_captions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        captionId TEXT,
        caption TEXT,
        isSynced INTEGER,
        createdAt TEXT,
        UNIQUE(userId, captionId) ON CONFLICT REPLACE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_notes_user ON notes(userId)');
    await db.execute('CREATE INDEX idx_favorites_user ON favorite_captions(userId)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE favorite_captions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT,
          captionId TEXT,
          caption TEXT,
          isSynced INTEGER,
          createdAt TEXT,
          UNIQUE(userId, captionId) ON CONFLICT REPLACE
        )
      ''');
      await db.execute('CREATE INDEX idx_favorites_user ON favorite_captions(userId)');
    }
  }



  /// ================== NOTES OPERATIONS ==================

  // Insert a note into the local database
  Future<void> insertNote(String userId, String noteId, String noteName, String note, bool isSynced) async {
    final db = await database;
    await db.insert(
      'notes',
      {
        'userId': userId,
        'noteId': noteId,
        'noteName': noteName,
        'note': note,
        'isSynced': isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update an existing note in the local database
  Future<void> updateNote(String userId, String noteId, String noteName, String note, bool isSynced) async {
    final db = await database;
    await db.update(
      'notes',
      {
        'noteName': noteName,
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



  /// ================== Fav Caption OPERATIONS ==================

  // Add to your existing DatabaseHelper class
  Future<void> insertFavoriteCaption(FavoriteCaption caption) async {
    print('============Inside database helper and insertFavoriteCaption=========');
    final db = await database;
    await db.insert(
      'favorite_captions',
      caption.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFavoriteCaption(String userId, String timestampKey) async {
    final db = await database;
    await db.delete(
      'favorite_captions',
      where: 'userId = ? AND captionId = ?',
      whereArgs: [userId, timestampKey],
    );
  }

  Future<List<FavoriteCaption>> getFavoriteCaptions(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorite_captions',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    final List<FavoriteCaption> favCaptions = maps.map((map) => FavoriteCaption.fromMap(map)).toList();
    return favCaptions;
  }

  Future<void> markFavoriteAsSynced(String userId, String captionId) async {
    final db = await database;
    await db.update(
      'favorite_captions',
      {'isSynced': 1},
      where: 'userId = ? AND captionId = ?',
      whereArgs: [userId, captionId],
    );
  }
}

