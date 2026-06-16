import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/achievement_local_datasource.dart';
import '../../data/repositories/achievement_repository_impl.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';
import 'game_provider.dart';

final achievementLocalDatasourceProvider = Provider<AchievementLocalDatasource>(
  (ref) => AchievementLocalDatasource(ref.watch(databaseHelperProvider)),
);

final achievementRepositoryProvider = Provider<AchievementRepository>(
  (ref) =>
      AchievementRepositoryImpl(ref.watch(achievementLocalDatasourceProvider)),
);

class AchievementsNotifier
    extends FamilyAsyncNotifier<List<Achievement>, String> {
  @override
  Future<List<Achievement>> build(String arg) =>
      ref.watch(achievementRepositoryProvider).getAchievementsByGame(arg);

  Future<void> add(Achievement achievement) async {
    await ref.read(achievementRepositoryProvider).saveAchievement(achievement);
    ref.invalidateSelf();
    ref.invalidate(gamesProvider);
  }

  Future<void> toggle(String achievementId, bool unlocked) async {
    await ref
        .read(achievementRepositoryProvider)
        .toggleAchievement(achievementId, unlocked);
    ref.invalidateSelf();
    ref.invalidate(gamesProvider);
  }
}

final achievementsNotifierProvider =
    AsyncNotifierProviderFamily<AchievementsNotifier, List<Achievement>, String>(
  AchievementsNotifier.new,
);
