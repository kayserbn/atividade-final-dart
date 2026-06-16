import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/entities/medal_tier.dart';
import 'game_cover_image.dart';
import 'medal_badge.dart';

class GameGridItem extends StatelessWidget {
  final Game game;
  const GameGridItem({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        'game-detail',
        pathParameters: {'id': game.id},
        extra: game.title,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: game.medalTier == MedalTier.diamond
                ? AppColors.diamond.withAlpha(102)
                : AppColors.surfaceVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: GameCoverImage(
                      imagePath: game.coverImagePath,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  if (game.medalTier != MedalTier.none)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: MedalBadge(tier: game.medalTier, size: 32),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: game.completionPercentage / 100,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor:
                          AlwaysStoppedAnimation(_tierColor(game.completionPercentage)),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${game.completionPercentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: _tierColor(game.completionPercentage),
                        ),
                  ),
                ],
              ),
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
