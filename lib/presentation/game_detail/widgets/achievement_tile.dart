import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/achievement.dart';

class AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final ValueChanged<bool> onToggle;

  const AchievementTile({
    super.key,
    required this.achievement,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.accent.withAlpha(20)
            : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked
              ? AppColors.accent.withAlpha(80)
              : AppColors.surfaceVariant,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: _AchievementIcon(unlocked: unlocked),
        title: Text(
          achievement.title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: unlocked
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (achievement.description != null &&
                achievement.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  achievement.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (unlocked && achievement.unlockedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Desbloqueada em ${_formatDate(achievement.unlockedAt!)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.accent, fontSize: 11),
                ),
              ),
          ],
        ),
        trailing: Checkbox(
          value: unlocked,
          onChanged: (v) => onToggle(v ?? false),
          activeColor: AppColors.accent,
          checkColor: AppColors.background,
          side: const BorderSide(color: AppColors.textMuted),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

class _AchievementIcon extends StatelessWidget {
  final bool unlocked;
  const _AchievementIcon({required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final icon = unlocked ? Icons.lock_open_rounded : Icons.lock_rounded;
    final color = unlocked ? AppColors.accent : AppColors.textMuted;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(26),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Icon(icon, color: color, size: 20),
    )
        .animate(target: unlocked ? 1.0 : 0.0)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0))
        .fadeIn();
  }
}
