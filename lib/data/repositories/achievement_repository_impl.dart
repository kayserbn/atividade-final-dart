import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../datasources/local/achievement_local_datasource.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final AchievementLocalDatasource _local;
  AchievementRepositoryImpl(this._local);

  @override
  Future<List<Achievement>> getAchievementsByGame(String gameId) =>
      _local.getByGame(gameId);

  @override
  Future<void> saveAchievement(Achievement achievement) =>
      _local.insert(achievement);

  @override
  Future<void> toggleAchievement(String id, bool isUnlocked) =>
      _local.toggle(id, isUnlocked);

  @override
  Future<void> deleteAchievementsByGame(String gameId) =>
      _local.deleteByGame(gameId);
}
