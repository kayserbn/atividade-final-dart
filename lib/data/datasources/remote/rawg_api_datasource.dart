import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/rawg_game_model.dart';

class RawgApiDatasource {
  late final Dio _dio;

  RawgApiDatasource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.rawgBaseUrl,
        queryParameters: {'key': AppConstants.rawgApiKey},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  Future<List<RawgGame>> searchGames(String query, {int page = 1}) async {
    final response = await _dio.get('/games', queryParameters: {
      'search': query,
      'page': page,
      'page_size': AppConstants.pageSize,
    });
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((e) => RawgGame.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RawgGame> getGameDetail(int rawgId) async {
    final response = await _dio.get('/games/$rawgId');
    return RawgGame.fromJson(response.data as Map<String, dynamic>);
  }
}
