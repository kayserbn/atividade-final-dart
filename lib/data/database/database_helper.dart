import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'game_achievements.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE games (
        id                TEXT PRIMARY KEY,
        title             TEXT NOT NULL,
        cover_image_path  TEXT,
        description       TEXT,
        sort_order        INTEGER NOT NULL DEFAULT 0,
        added_at          TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id          TEXT PRIMARY KEY,
        game_id     TEXT NOT NULL,
        title       TEXT NOT NULL,
        description TEXT,
        icon_path   TEXT,
        is_unlocked INTEGER NOT NULL DEFAULT 0,
        unlocked_at TEXT,
        FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE
      )
    ''');
  }
}
