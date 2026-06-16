import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/medal_tier.dart';

class MedalBadge extends StatelessWidget {
  final MedalTier tier;
  final double size;

  const MedalBadge({super.key, required this.tier, this.size = 28});

  @override
  Widget build(BuildContext context) {
    if (tier == MedalTier.none) return const SizedBox.shrink();

    final color = switch (tier) {
      MedalTier.bronze  => AppColors.bronze,
      MedalTier.silver  => AppColors.silver,
      MedalTier.gold    => AppColors.gold,
      MedalTier.diamond => AppColors.diamond,
      MedalTier.none    => Colors.transparent,
    };

    final icon = switch (tier) {
      MedalTier.diamond => Icons.diamond_rounded,
      MedalTier.gold    => Icons.military_tech_rounded,
      _                 => Icons.emoji_events_rounded,
    };

    final container = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(38),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(icon, color: color, size: size * 0.58),
    );

    if (tier == MedalTier.diamond) {
      // Shimmer único — roda cada vez que o widget é reconstruído (ex: ao scrollar)
      return container
          .animate()
          .shimmer(duration: 1800.ms, color: color.withAlpha(128));
    }

    return container;
  }
}
