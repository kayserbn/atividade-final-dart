import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import 'widgets/add_game_sheet.dart';
import 'widgets/game_card.dart';
import 'widgets/game_grid_item.dart';
import 'widgets/home_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider);
    final isGrid = ref.watch(gridViewProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const HomeHeader(),
        actions: [
          IconButton(
            icon: Icon(
              isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppColors.accent,
            ),
            tooltip: isGrid ? 'Ver como lista' : 'Ver como grade',
            onPressed: () => ref.read(gridViewProvider.notifier).toggle(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: gamesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Erro ao carregar games: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (games) {
          if (games.isEmpty) return _EmptyState();
          return isGrid ? _GridView(games: games) : _ListView(games: games);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSheet(context),
        tooltip: 'Adicionar game',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddGameSheet(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_esports_outlined,
              size: 80, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Nenhum game ainda',
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em + para adicionar seu primeiro game',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}

class _ListView extends StatelessWidget {
  final List games;
  const _ListView({required this.games});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: games.length,
      itemBuilder: (_, i) => GameCard(game: games[i])
          .animate(delay: (i * 60).ms)
          .fadeIn()
          .slideX(begin: 0.1),
    );
  }
}

class _GridView extends StatelessWidget {
  final List games;
  const _GridView({required this.games});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: games.length,
      itemBuilder: (_, i) => GameGridItem(game: games[i])
          .animate(delay: (i * 60).ms)
          .fadeIn()
          .slideY(begin: 0.15),
    );
  }
}
