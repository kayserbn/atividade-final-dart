import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String gameId;
  final String title;
  final String? description;
  final String? iconPath;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.gameId,
    required this.title,
    this.description,
    this.iconPath,
    required this.isUnlocked,
    this.unlockedAt,
  });

  Achievement copyWith({bool? isUnlocked, DateTime? unlockedAt}) => Achievement(
        id: id,
        gameId: gameId,
        title: title,
        description: description,
        iconPath: iconPath,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );

  @override
  List<Object?> get props =>
      [id, gameId, title, description, iconPath, isUnlocked, unlockedAt];
}
