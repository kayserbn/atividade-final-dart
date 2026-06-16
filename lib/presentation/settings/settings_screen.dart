import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/medal_tier.dart';
import '../home/widgets/medal_badge.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider);
    final isGrid = ref.watch(gridViewProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: 'Visualização'),
          const SizedBox(height: 8),
          _LayoutToggleTile(isGrid: isGrid, ref: ref),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Reordenar Games'),
          const SizedBox(height: 8),
          gamesAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Text('Erro: $e', style: const TextStyle(color: AppColors.error)),
            data: (games) => games.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Nenhum game para reordenar',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: games.length,
                    onReorderItem: (oldIndex, newIndex) {
                      final reordered = [...games];
                      final item = reordered.removeAt(oldIndex);
                      reordered.insert(newIndex, item);
                      ref.read(gamesProvider.notifier).reorder(
                            reordered.map((g) => g.id).toList(),
                          );
                    },
                    itemBuilder: (ctx, i) => Material(
                      key: ValueKey(games[i].id),
                      color: Colors.transparent,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.surfaceVariant),
                        ),
                        child: ListTile(
                          leading: ReorderableDragStartListener(
                            index: i,
                            child: const Icon(Icons.drag_handle_rounded,
                                color: AppColors.textMuted),
                          ),
                          title: Text(games[i].title,
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          subtitle: Text(
                            '${games[i].completionPercentage.toStringAsFixed(0)}% — ${games[i].medalTier.label}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
                          trailing: MedalBadge(tier: games[i].medalTier),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
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

class _LayoutToggleTile extends StatelessWidget {
  final bool isGrid;
  final WidgetRef ref;
  const _LayoutToggleTile({required this.isGrid, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: ListTile(
        leading: Icon(
          isGrid ? Icons.grid_view_rounded : Icons.view_list_rounded,
          color: AppColors.accent,
        ),
        title: const Text('Layout da lista de games'),
        subtitle: Text(
          isGrid ? 'Grade (2 colunas)' : 'Lista',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        trailing: Switch(
          value: isGrid,
          onChanged: (_) => ref.read(gridViewProvider.notifier).toggle(),
          activeThumbColor: AppColors.accent,
        ),
      ),
    );
  }
}
