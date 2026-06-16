import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/rawg_game_model.dart';
import '../../../domain/entities/game.dart';
import '../../providers/game_provider.dart';
import '../../providers/search_provider.dart';
import 'game_cover_image.dart';

class AddGameSheet extends ConsumerStatefulWidget {
  const AddGameSheet({super.key});

  @override
  ConsumerState<AddGameSheet> createState() => _AddGameSheetState();
}

class _AddGameSheetState extends ConsumerState<AddGameSheet> {
  final _ctrl = TextEditingController();
  static const _uuid = Uuid();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _query = value.trim());
    });
  }

  Future<void> _addFromRawg(RawgGame rawg, int sortOrder) async {
    await ref.read(gamesProvider.notifier).addGame(Game(
          id: _uuid.v4(),
          title: rawg.name,
          coverImagePath: rawg.backgroundImage,
          description: rawg.description,
          totalAchievements: 0,
          unlockedAchievements: 0,
          sortOrder: sortOrder,
          addedAt: DateTime.now(),
        ));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _addManually(String title, int sortOrder) async {
    if (title.trim().isEmpty) return;
    await ref.read(gamesProvider.notifier).addGame(Game(
          id: _uuid.v4(),
          title: title.trim(),
          totalAchievements: 0,
          unlockedAchievements: 0,
          sortOrder: sortOrder,
          addedAt: DateTime.now(),
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentGames = ref.watch(gamesProvider).valueOrNull ?? [];
    final searchAsync = ref.watch(rawgSearchProvider(_query));
    final hasText = _ctrl.text.trim().isNotEmpty;

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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Adicionar Game',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: _onChanged,
            decoration: const InputDecoration(
              hintText: 'Buscar na RAWG API...',
              prefixIcon:
                  Icon(Icons.search_rounded, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: _query.isEmpty
                ? const SizedBox.shrink()
                : searchAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Erro ao buscar. Verifique sua chave RAWG.',
                          style: const TextStyle(color: AppColors.error)),
                    ),
                    data: (results) => results.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('Nenhum resultado para "$_query"',
                                style: const TextStyle(
                                    color: AppColors.textMuted)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: results.length,
                            itemBuilder: (ctx, i) => _RawgTile(
                              game: results[i],
                              onTap: () =>
                                  _addFromRawg(results[i], currentGames.length),
                            )
                                .animate(delay: (i * 40).ms)
                                .fadeIn()
                                .slideX(begin: 0.1),
                          ),
                  ),
          ),
          if (hasText)
            TextButton.icon(
              onPressed: () => _addManually(_ctrl.text, currentGames.length),
              icon: const Icon(Icons.add_rounded, color: AppColors.accent),
              label: Text(
                'Adicionar "${_ctrl.text.trim()}" manualmente',
                style: const TextStyle(color: AppColors.accent),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RawgTile extends StatelessWidget {
  final RawgGame game;
  final VoidCallback onTap;
  const _RawgTile({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GameCoverImage(imagePath: game.backgroundImage, width: 52, height: 52),
      ),
      title: Text(game.name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: game.rating != null
          ? Text('★ ${game.rating!.toStringAsFixed(1)}',
              style: const TextStyle(color: AppColors.gold, fontSize: 12))
          : null,
      trailing: const Icon(Icons.add_circle_outline_rounded,
          color: AppColors.accent),
      onTap: onTap,
    );
  }
}
