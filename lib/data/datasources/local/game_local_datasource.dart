import 'package:sqflite/sqflite.dart';
import '../../database/database_helper.dart';
import '../../models/game_model.dart';
import '../../../domain/entities/game.dart';

class GameLocalDatasource {
  final DatabaseHelper _dbHelper;
  GameLocalDatasource(this._dbHelper);

  Future<List<Game>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT g.*,
        COUNT(a.id) AS total_achievements,
        SUM(CASE WHEN a.is_unlocked = 1 THEN 1 ELSE 0 END) AS unlocked_achievements
      FROM games g
      LEFT JOIN achievements a ON a.game_id = g.id
      GROUP BY g.id
      ORDER BY g.sort_order ASC
    ''');
    return rows.map((r) {
      final model = GameModel.fromMap(r);
      return model.toEntity(
        total:    (r['total_achievements'] as int?) ?? 0,
        unlocked: (r['unlocked_achievements'] as int?) ?? 0,
      );
    }).toList();
  }

  Future<Game?> getById(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT g.*,
        COUNT(a.id) AS total_achievements,
        SUM(CASE WHEN a.is_unlocked = 1 THEN 1 ELSE 0 END) AS unlocked_achievements
      FROM games g
      LEFT JOIN achievements a ON a.game_id = g.id
      WHERE g.id = ?
      GROUP BY g.id
    ''', [id]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return GameModel.fromMap(r).toEntity(
      total:    (r['total_achievements'] as int?) ?? 0,
      unlocked: (r['unlocked_achievements'] as int?) ?? 0,
    );
  }

  Future<void> insert(Game game) async {
    final db = await _dbHelper.database;
    await db.insert(
      'games',
      GameModel.fromEntity(game).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Game game) async {
    final db = await _dbHelper.database;
    await db.update(
      'games',
      {
        'title': game.title,
        'cover_image_path': game.coverImagePath,
        'description': game.description,
        'sort_order': game.sortOrder,
      },
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> reorder(List<String> orderedIds) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (var i = 0; i < orderedIds.length; i++) {
        await txn.update(
          'games',
          {'sort_order': i},
          where: 'id = ?',
          whereArgs: [orderedIds[i]],
        );
      }
    });
  }
}
