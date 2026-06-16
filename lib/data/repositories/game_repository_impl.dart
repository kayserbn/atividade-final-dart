import '../../domain/entities/game.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local/game_local_datasource.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLocalDatasource _local;
  GameRepositoryImpl(this._local);

  @override
  Future<List<Game>> getAllGames() => _local.getAll();

  @override
  Future<Game?> getGameById(String id) => _local.getById(id);

  @override
  Future<void> saveGame(Game game) => _local.insert(game);

  @override
  Future<void> updateGame(Game game) => _local.update(game);

  @override
  Future<void> deleteGame(String id) => _local.delete(id);

  @override
  Future<void> reorderGames(List<String> orderedIds) => _local.reorder(orderedIds);
}
