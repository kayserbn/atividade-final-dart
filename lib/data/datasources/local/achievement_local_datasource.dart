import 'package:sqflite/sqflite.dart';
import '../../database/database_helper.dart';
import '../../models/achievement_model.dart';
import '../../../domain/entities/achievement.dart';

class AchievementLocalDatasource {
  final DatabaseHelper _dbHelper;
  AchievementLocalDatasource(this._dbHelper);

  Future<List<Achievement>> getByGame(String gameId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'achievements',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
    return rows.map((r) => AchievementModel.fromMap(r).toEntity()).toList();
  }

  Future<void> insert(Achievement achievement) async {
    final db = await _dbHelper.database;
    await db.insert(
      'achievements',
      AchievementModel.fromEntity(achievement).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> toggle(String id, bool isUnlocked) async {
    final db = await _dbHelper.database;
    await db.update(
      'achievements',
      {
        'is_unlocked': isUnlocked ? 1 : 0,
        'unlocked_at': isUnlocked ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByGame(String gameId) async {
    final db = await _dbHelper.database;
    await db.delete('achievements', where: 'game_id = ?', whereArgs: [gameId]);
  }
}
