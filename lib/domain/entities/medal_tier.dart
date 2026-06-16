enum MedalTier { none, bronze, silver, gold, diamond }

extension MedalTierExtension on MedalTier {
  static MedalTier fromPercentage(double percent) {
    if (percent >= 100) return MedalTier.diamond;
    if (percent >= 75)  return MedalTier.gold;
    if (percent >= 50)  return MedalTier.silver;
    if (percent >= 25)  return MedalTier.bronze;
    return MedalTier.none;
  }

  String get label => switch (this) {
    MedalTier.none    => 'Sem medalha',
    MedalTier.bronze  => 'Bronze',
    MedalTier.silver  => 'Prata',
    MedalTier.gold    => 'Ouro',
    MedalTier.diamond => 'Diamante',
  };
}
