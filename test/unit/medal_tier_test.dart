import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/domain/entities/medal_tier.dart';

void main() {
  group('MedalTierExtension.fromPercentage', () {
    test('retorna none para menos de 25%', () {
      expect(MedalTierExtension.fromPercentage(0), MedalTier.none);
      expect(MedalTierExtension.fromPercentage(24.9), MedalTier.none);
    });

    test('retorna bronze para 25% a 49%', () {
      expect(MedalTierExtension.fromPercentage(25), MedalTier.bronze);
      expect(MedalTierExtension.fromPercentage(49.9), MedalTier.bronze);
    });

    test('retorna silver para 50% a 74%', () {
      expect(MedalTierExtension.fromPercentage(50), MedalTier.silver);
      expect(MedalTierExtension.fromPercentage(74.9), MedalTier.silver);
    });

    test('retorna gold para 75% a 99%', () {
      expect(MedalTierExtension.fromPercentage(75), MedalTier.gold);
      expect(MedalTierExtension.fromPercentage(99.9), MedalTier.gold);
    });

    test('retorna diamond para 100%', () {
      expect(MedalTierExtension.fromPercentage(100), MedalTier.diamond);
    });
  });

  group('MedalTier.label', () {
    test('todos os tiers têm labels corretos', () {
      expect(MedalTier.none.label, 'Sem medalha');
      expect(MedalTier.bronze.label, 'Bronze');
      expect(MedalTier.silver.label, 'Prata');
      expect(MedalTier.gold.label, 'Ouro');
      expect(MedalTier.diamond.label, 'Diamante');
    });
  });
}
