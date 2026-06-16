import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/core/theme/app_theme.dart';
import 'package:game_achievements/domain/entities/game.dart';
import 'package:game_achievements/presentation/home/widgets/game_card.dart';
import 'package:go_router/go_router.dart';

Widget _wrap(Widget child) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(body: child),
      ),
      GoRoute(
        path: '/game/:id',
        name: 'game-detail',
        builder: (_, _) => const SizedBox(),
      ),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      theme: AppTheme.dark,
      routerConfig: router,
    ),
  );
}

void main() {
  final fakeGame = Game(
    id: '1',
    title: 'Hollow Knight',
    totalAchievements: 10,
    unlockedAchievements: 5,
    sortOrder: 0,
    addedAt: DateTime(2024),
  );

  testWidgets('GameCard exibe o título do game', (tester) async {
    await tester.pumpWidget(_wrap(GameCard(game: fakeGame)));
    await tester.pumpAndSettle();
    expect(find.text('Hollow Knight'), findsOneWidget);
  });

  testWidgets('GameCard exibe contagem de conquistas', (tester) async {
    await tester.pumpWidget(_wrap(GameCard(game: fakeGame)));
    await tester.pumpAndSettle();
    expect(find.textContaining('5 / 10'), findsOneWidget);
  });

  testWidgets('GameCard exibe percentual de progresso', (tester) async {
    await tester.pumpWidget(_wrap(GameCard(game: fakeGame)));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('50%'), findsOneWidget);
  });
}
