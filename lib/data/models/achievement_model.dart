import '../../domain/entities/achievement.dart';

class AchievementModel {
  final String id;
  final String gameId;
  final String title;
  final String? description;
  final String? iconPath;
  final int isUnlocked;
  final String? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.gameId,
    required this.title,
    this.description,
    this.iconPath,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory AchievementModel.fromMap(Map<String, dynamic> map) => AchievementModel(
        id: map['id'] as String,
        gameId: map['game_id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        iconPath: map['icon_path'] as String?,
        isUnlocked: map['is_unlocked'] as int,
        unlockedAt: map['unlocked_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'game_id': gameId,
        'title': title,
        'description': description,
        'icon_path': iconPath,
        'is_unlocked': isUnlocked,
        'unlocked_at': unlockedAt,
      };

  Achievement toEntity() => Achievement(
        id: id,
        gameId: gameId,
        title: title,
        description: description,
        iconPath: iconPath,
        isUnlocked: isUnlocked == 1,
        unlockedAt: unlockedAt != null ? DateTime.parse(unlockedAt!) : null,
      );

  factory AchievementModel.fromEntity(Achievement a) => AchievementModel(
        id: a.id,
        gameId: a.gameId,
        title: a.title,
        description: a.description,
        iconPath: a.iconPath,
        isUnlocked: a.isUnlocked ? 1 : 0,
        unlockedAt: a.unlockedAt?.toIso8601String(),
      );
}
