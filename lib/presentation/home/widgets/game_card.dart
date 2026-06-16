import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/entities/medal_tier.dart';
import 'game_cover_image.dart';
import 'medal_badge.dart';

class GameCard extends StatelessWidget {
  final Game game;
  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        'game-detail',
        pathParameters: {'id': game.id},
        extra: game.title,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: game.medalTier == MedalTier.diamond
                ? AppColors.diamond.withAlpha(102)
                : AppColors.surfaceVariant,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: GameCoverImage(
                imagePath: game.coverImagePath,
                width: 90,
                height: 100,
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            game.title,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MedalBadge(tier: game.medalTier),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${game.unlockedAchievements} / ${game.totalAchievements} conquistas',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    _ProgressBar(percentage: game.completionPercentage),
                    const SizedBox(height: 4),
                    Text(
                      '${game.completionPercentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: _tierColor(game.completionPercentage),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  static Color _tierColor(double pct) {
    if (pct >= 100) return AppColors.diamond;
    if (pct >= 75) return AppColors.gold;
    if (pct >= 50) return AppColors.silver;
    if (pct >= 25) return AppColors.bronze;
    return AppColors.textMuted;
  }
}

class _ProgressBar extends StatelessWidget {
  final double percentage;
  const _ProgressBar({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final color = GameCard._tierColor(percentage);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percentage / 100),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (_, value, _) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: AppColors.surfaceVariant,
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 5,
        ),
      ),
    );
  }
}
