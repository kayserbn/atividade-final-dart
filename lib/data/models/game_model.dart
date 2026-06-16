import '../../domain/entities/game.dart';

class GameModel {
  final String id;
  final String title;
  final String? coverImagePath;
  final String? description;
  final int sortOrder;
  final String addedAt;

  const GameModel({
    required this.id,
    required this.title,
    this.coverImagePath,
    this.description,
    required this.sortOrder,
    required this.addedAt,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) => GameModel(
        id: map['id'] as String,
        title: map['title'] as String,
        coverImagePath: map['cover_image_path'] as String?,
        description: map['description'] as String?,
        sortOrder: map['sort_order'] as int,
        addedAt: map['added_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'cover_image_path': coverImagePath,
        'description': description,
        'sort_order': sortOrder,
        'added_at': addedAt,
      };

  Game toEntity({int total = 0, int unlocked = 0}) => Game(
        id: id,
        title: title,
        coverImagePath: coverImagePath,
        description: description,
        totalAchievements: total,
        unlockedAchievements: unlocked,
        sortOrder: sortOrder,
        addedAt: DateTime.parse(addedAt),
      );

  factory GameModel.fromEntity(Game game) => GameModel(
        id: game.id,
        title: game.title,
        coverImagePath: game.coverImagePath,
        description: game.description,
        sortOrder: game.sortOrder,
        addedAt: game.addedAt.toIso8601String(),
      );
}
