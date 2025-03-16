import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diary_entry.dart';
import '../models/caption_category.dart';
import '../models/caption.dart';

class LocalDBService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'app_data.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE diary (id TEXT PRIMARY KEY, title TEXT, content TEXT, date TEXT)');
        await db.execute(
            'CREATE TABLE categories (id TEXT PRIMARY KEY, name TEXT)');
        await db.execute(
            'CREATE TABLE captions (id TEXT PRIMARY KEY, text TEXT, categoryId TEXT)');
      },
    );
  }

  // ✅ Insert a single diary entry
  Future<void> insertDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    await db.insert('diary', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ✅ Insert multiple diary entries (Fix for missing method)
  Future<void> insertDiaryEntries(List<DiaryEntry> entries) async {
    final db = await database;
    final batch = db.batch();

    for (var entry in entries) {
      batch.insert('diary', entry.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  // ✅ Fetch all diary entries
  Future<List<DiaryEntry>> getDiaryEntries() async {
    final db = await database;
    final result = await db.query('diary');
    return result.map((e) => DiaryEntry.fromMap(e)).toList();
  }

  // ✅ Insert multiple categories
  // Future<void> insertCategories(List<CaptionCategory> categories) async {
  //   final db = await database;
  //   for (var category in categories) {
  //     await db.insert('categories', category.toMap(),
  //         conflictAlgorithm: ConflictAlgorithm.replace);
  //   }
  // }

  // ✅ Fetch all categories
  // Future<List<CaptionCategory>> getCategories() async {
  //   final db = await database;
  //   final result = await db.query('categories');
  //   return result.map((e) => CaptionCategory.fromMap(e)).toList();
  // }
}
