import '../entities/achievement.dart';

abstract interface class AchievementRepository {
  Future<List<Achievement>> getAchievementsByGame(String gameId);
  Future<void> saveAchievement(Achievement achievement);
  Future<void> toggleAchievement(String id, bool isUnlocked);
  Future<void> deleteAchievementsByGame(String gameId);
}
