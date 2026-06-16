import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/medal_tier.dart';
import '../../domain/entities/user_profile.dart';
import '../home/widgets/game_cover_image.dart';
import '../home/widgets/medal_badge.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import 'widgets/profile_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final gamesAsync = ref.watch(gamesProvider);
    final profile = profileAsync.valueOrNull;
    final games = gamesAsync.valueOrNull ?? [];

    final diamondGames =
        games.where((g) => g.medalTier == MedalTier.diamond).toList();
    final completedGames =
        games.where((g) => g.completionPercentage == 100).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          const SizedBox(height: 12),
          Center(
            child: ProfileAvatar(profile: profile)
                .animate()
                .fadeIn()
                .scale(begin: const Offset(0.85, 0.85)),
          ),
          const SizedBox(height: 20),
          Center(
            child: _NicknameSection(profile: profile),
          ),
          const SizedBox(height: 32),
          _StatsRow(
            totalGames: games.length,
            completedGames: completedGames,
            diamondGames: diamondGames.length,
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
          if (diamondGames.isNotEmpty) ...[
            const SizedBox(height: 32),
            _SectionTitle(title: 'Games Diamante'),
            const SizedBox(height: 12),
            _DiamondShowcase(games: diamondGames),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _NicknameSection extends ConsumerStatefulWidget {
  final UserProfile? profile;
  const _NicknameSection({this.profile});

  @override
  ConsumerState<_NicknameSection> createState() => _NicknameSectionState();
}

class _NicknameSectionState extends ConsumerState<_NicknameSection> {
  late final TextEditingController _ctrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.profile?.nickname ?? 'Jogador');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_editing)
          SizedBox(
            width: 200,
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            ),
          )
        else
          Text(
            widget.profile?.nickname ?? 'Jogador',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(
            _editing ? Icons.check_rounded : Icons.edit_rounded,
            color: AppColors.accent,
            size: 22,
          ),
          onPressed: () async {
            if (_editing) {
              final current = widget.profile ??
                  UserProfile(
                      nickname: _ctrl.text, createdAt: DateTime.now());
              await ref
                  .read(userProfileProvider.notifier)
                  .save(current.copyWith(nickname: _ctrl.text.trim()));
            }
            setState(() => _editing = !_editing);
          },
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalGames;
  final int completedGames;
  final int diamondGames;

  const _StatsRow({
    required this.totalGames,
    required this.completedGames,
    required this.diamondGames,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(value: '$totalGames', label: 'Games'),
          _divider(),
          _Stat(value: '$completedGames', label: '100%'),
          _divider(),
          _Stat(
              value: '$diamondGames',
              label: 'Diamante',
              color: AppColors.diamond),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 40, color: AppColors.surfaceVariant);
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;

  const _Stat({required this.value, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: color ?? AppColors.accent),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .labelLarge!
          .copyWith(color: AppColors.accent),
    );
  }
}

class _DiamondShowcase extends StatelessWidget {
  final List games;
  const _DiamondShowcase({required this.games});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () => context.pushNamed(
            'game-detail',
            pathParameters: {'id': games[i].id},
            extra: games[i].title as String,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GameCoverImage(
                  imagePath: games[i].coverImagePath as String?,
                  width: 90,
                  height: 120,
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: MedalBadge(tier: MedalTier.diamond, size: 28),
              ),
            ],
          ),
        ).animate(delay: (i * 60).ms).fadeIn().slideX(begin: 0.1),
      ),
    );
  }
}
