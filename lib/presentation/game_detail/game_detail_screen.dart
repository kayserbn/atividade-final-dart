import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/iterable_extensions.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/game.dart';
import '../home/widgets/game_cover_image.dart';
import '../providers/achievement_provider.dart';
import '../providers/game_provider.dart';
import 'widgets/achievement_tile.dart';
import 'widgets/progress_header.dart';

class GameDetailScreen extends ConsumerWidget {
  final String gameId;
  final String gameTitle;

  const GameDetailScreen({
    super.key,
    required this.gameId,
    required this.gameTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider);
    final achievementsAsync = ref.watch(achievementsNotifierProvider(gameId));

    final game = gamesAsync.valueOrNull
        ?.firstWhereOrNull((g) => g.id == gameId);

    final achievements = achievementsAsync.valueOrNull ?? [];
    final isLoading =
        gamesAsync.isLoading || achievementsAsync.isLoading;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(gameTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(game?.title ?? gameTitle),
        actions: [
          if (game != null)
            PopupMenuButton<_GameAction>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (action) async {
                switch (action) {
                  case _GameAction.changeCover:
                    await _changeCover(context, ref, game);
                  case _GameAction.delete:
                    await _confirmDelete(context, ref);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: _GameAction.changeCover,
                  child: ListTile(
                    leading: Icon(Icons.image_rounded),
                    title: Text('Mudar capa'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: _GameAction.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete_rounded, color: AppColors.error),
                    title: Text('Excluir game',
                        style: TextStyle(color: AppColors.error)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        children: [
          if (game != null) _CoverSection(game: game),
          ProgressHeader(achievements: achievements),
          if (achievements.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_outlined,
                      size: 60, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('Nenhuma conquista ainda',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColors.textMuted)),
                ],
              ).animate().fadeIn(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < achievements.length; i++)
                    AchievementTile(
                      achievement: achievements[i],
                      onToggle: (unlocked) => ref
                          .read(achievementsNotifierProvider(gameId).notifier)
                          .toggle(achievements[i].id, unlocked),
                    )
                        .animate(delay: (i * 40).ms)
                        .fadeIn()
                        .slideX(begin: 0.08),
                ],
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddAchievementSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Conquista'),
      ),
    );
  }

  Future<void> _changeCover(
      BuildContext context, WidgetRef ref, Game game) async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    await ref
        .read(gamesProvider.notifier)
        .updateGame(game.copyWith(coverImagePath: picked.path));
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Excluir game?'),
        content: const Text(
            'Todas as conquistas deste game serão removidas.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(gamesProvider.notifier).deleteGame(gameId);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  void _openAddAchievementSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddAchievementSheet(gameId: gameId, ref: ref),
    );
  }
}

enum _GameAction { changeCover, delete }

class _CoverSection extends StatelessWidget {
  final Game game;
  const _CoverSection({required this.game});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GameCoverImage(
        imagePath: game.coverImagePath,
        width: double.infinity,
        height: 200,
      ),
    );
  }
}

class _AddAchievementSheet extends StatefulWidget {
  final String gameId;
  final WidgetRef ref;
  const _AddAchievementSheet({required this.gameId, required this.ref});

  @override
  State<_AddAchievementSheet> createState() => _AddAchievementSheetState();
}

class _AddAchievementSheetState extends State<_AddAchievementSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  static const _uuid = Uuid();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    await widget.ref
        .read(achievementsNotifierProvider(widget.gameId).notifier)
        .add(Achievement(
          id: _uuid.v4(),
          gameId: widget.gameId,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          isUnlocked: false,
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Nova Conquista',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            decoration:
                const InputDecoration(hintText: 'Nome da conquista *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
                hintText: 'Descrição (opcional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Adicionar'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
