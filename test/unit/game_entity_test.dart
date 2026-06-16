import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/domain/entities/game.dart';
import 'package:game_achievements/domain/entities/medal_tier.dart';

void main() {
  final base = Game(
    id: '1',
    title: 'Hollow Knight',
    totalAchievements: 40,
    unlockedAchievements: 30,
    sortOrder: 0,
    addedAt: DateTime(2024),
  );

  group('Game.completionPercentage', () {
    test('calcula 75% corretamente', () {
      expect(base.completionPercentage, 75.0);
    });

    test('retorna 0 quando totalAchievements é zero', () {
      final g = base.copyWith(totalAchievements: 0, unlockedAchievements: 0);
      expect(g.completionPercentage, 0.0);
    });

    test('retorna 100 quando todos desbloqueados', () {
      final g = base.copyWith(unlockedAchievements: 40);
      expect(g.completionPercentage, 100.0);
    });
  });

  group('Game.medalTier', () {
    test('75% resulta em gold', () {
      expect(base.medalTier, MedalTier.gold);
    });

    test('100% resulta em diamond', () {
      final g = base.copyWith(unlockedAchievements: 40);
      expect(g.medalTier, MedalTier.diamond);
    });

    test('0% resulta em none', () {
      final g = base.copyWith(unlockedAchievements: 0);
      expect(g.medalTier, MedalTier.none);
    });
  });

  group('Game.copyWith', () {
    test('preserva campos não modificados', () {
      final updated = base.copyWith(title: 'Celeste');
      expect(updated.id, '1');
      expect(updated.title, 'Celeste');
      expect(updated.totalAchievements, 40);
      expect(updated.addedAt, DateTime(2024));
    });

    test('equatable: dois games iguais são iguais', () {
      final copy = base.copyWith();
      expect(copy, base);
    });
  });
}
