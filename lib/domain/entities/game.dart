import 'package:equatable/equatable.dart';
import 'medal_tier.dart';

class Game extends Equatable {
  final String id;
  final String title;
  final String? coverImagePath;
  final String? description;
  final int totalAchievements;
  final int unlockedAchievements;
  final int sortOrder;
  final DateTime addedAt;

  const Game({
    required this.id,
    required this.title,
    this.coverImagePath,
    this.description,
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.sortOrder,
    required this.addedAt,
  });

  double get completionPercentage =>
      totalAchievements == 0 ? 0 : (unlockedAchievements / totalAchievements) * 100;

  MedalTier get medalTier =>
      MedalTierExtension.fromPercentage(completionPercentage);

  Game copyWith({
    String? title,
    String? coverImagePath,
    String? description,
    int? totalAchievements,
    int? unlockedAchievements,
    int? sortOrder,
  }) =>
      Game(
        id: id,
        title: title ?? this.title,
        coverImagePath: coverImagePath ?? this.coverImagePath,
        description: description ?? this.description,
        totalAchievements: totalAchievements ?? this.totalAchievements,
        unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
        sortOrder: sortOrder ?? this.sortOrder,
        addedAt: addedAt,
      );

  @override
  List<Object?> get props => [
        id, title, coverImagePath, description,
        totalAchievements, unlockedAchievements, sortOrder, addedAt,
      ];
}
