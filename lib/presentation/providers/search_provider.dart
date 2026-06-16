import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/rawg_api_datasource.dart';
import '../../data/models/rawg_game_model.dart';

final rawgApiDatasourceProvider = Provider<RawgApiDatasource>(
  (_) => RawgApiDatasource(),
);

final rawgSearchProvider =
    FutureProvider.family<List<RawgGame>, String>((ref, query) {
  if (query.trim().isEmpty) return Future.value([]);
  return ref.watch(rawgApiDatasourceProvider).searchGames(query);
});
