import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database_helper.dart';
import '../../data/datasources/local/game_local_datasource.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/entities/game.dart';
import '../../domain/repositories/game_repository.dart';

final databaseHelperProvider = Provider<DatabaseHelper>(
  (_) => DatabaseHelper.instance,
);

final gameLocalDatasourceProvider = Provider<GameLocalDatasource>(
  (ref) => GameLocalDatasource(ref.watch(databaseHelperProvider)),
);

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepositoryImpl(ref.watch(gameLocalDatasourceProvider)),
);

class GamesNotifier extends AsyncNotifier<List<Game>> {
  @override
  Future<List<Game>> build() =>
      ref.watch(gameRepositoryProvider).getAllGames();

  Future<void> addGame(Game game) async {
    await ref.read(gameRepositoryProvider).saveGame(game);
    ref.invalidateSelf();
  }

  Future<void> updateGame(Game game) async {
    await ref.read(gameRepositoryProvider).updateGame(game);
    ref.invalidateSelf();
  }

  Future<void> deleteGame(String id) async {
    await ref.read(gameRepositoryProvider).deleteGame(id);
    ref.invalidateSelf();
  }

  Future<void> reorder(List<String> orderedIds) async {
    await ref.read(gameRepositoryProvider).reorderGames(orderedIds);
    ref.invalidateSelf();
  }
}

final gamesProvider = AsyncNotifierProvider<GamesNotifier, List<Game>>(
  GamesNotifier.new,
);
