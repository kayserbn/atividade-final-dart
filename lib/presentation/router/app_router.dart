import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../home/home_screen.dart';
import '../game_detail/game_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/constants/app_colors.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/game/:id',
        name: 'game-detail',
        builder: (context, state) {
          final gameId = state.pathParameters['id']!;
          final gameTitle = state.extra as String? ?? '';
          return GameDetailScreen(gameId: gameId, gameTitle: gameTitle);
        },
      ),
    ],
  );
});

class _AppShell extends ConsumerWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    const tabs = [
      (path: '/',         icon: Icons.sports_esports_rounded, label: 'Games'),
      (path: '/profile',  icon: Icons.person_rounded,          label: 'Perfil'),
      (path: '/settings', icon: Icons.tune_rounded,            label: 'Config'),
    ];

    int currentIndex = tabs.indexWhere((t) => location == t.path);
    if (currentIndex < 0) currentIndex = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.surfaceVariant, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => context.go(tabs[i].path),
          destinations: [
            for (final t in tabs)
              NavigationDestination(icon: Icon(t.icon), label: t.label),
          ],
        ),
      ),
    );
  }
}
