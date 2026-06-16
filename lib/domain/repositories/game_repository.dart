import '../entities/game.dart';

abstract interface class GameRepository {
  Future<List<Game>> getAllGames();
  Future<Game?> getGameById(String id);
  Future<void> saveGame(Game game);
  Future<void> updateGame(Game game);
  Future<void> deleteGame(String id);
  Future<void> reorderGames(List<String> orderedIds);
}
