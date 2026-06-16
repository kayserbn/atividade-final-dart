import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/achievement.dart';
import '../../../domain/entities/medal_tier.dart';
import '../../home/widgets/medal_badge.dart';

class ProgressHeader extends StatelessWidget {
  final List<Achievement> achievements;
  const ProgressHeader({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    final total = achievements.length;
    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final pct = total == 0 ? 0.0 : unlocked / total * 100;
    final tier = MedalTierExtension.fromPercentage(pct);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tier == MedalTier.diamond
              ? AppColors.diamond.withAlpha(128)
              : AppColors.surfaceVariant,
        ),
      ),
      child: Row(
        children: [
          MedalBadge(tier: tier, size: 52),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unlocked / $total conquistas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct / 100),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.accent),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${pct.toStringAsFixed(0)}% — ${tier.label}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.97, 0.97));
  }
}
