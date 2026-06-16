import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/core/theme/app_theme.dart';
import 'package:game_achievements/domain/entities/achievement.dart';
import 'package:game_achievements/presentation/game_detail/widgets/progress_header.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('ProgressHeader exibe "0 / 0 conquistas" sem dados',
      (tester) async {
    await tester.pumpWidget(_wrap(const ProgressHeader(achievements: [])));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('0 / 0'), findsOneWidget);
  });

  testWidgets('ProgressHeader exibe contagem correta de desbloqueados',
      (tester) async {
    final achievements = [
      const Achievement(id: '1', gameId: 'g1', title: 'A', isUnlocked: true),
      const Achievement(id: '2', gameId: 'g1', title: 'B', isUnlocked: false),
    ];
    await tester.pumpWidget(_wrap(ProgressHeader(achievements: achievements)));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('1 / 2'), findsOneWidget);
  });

  testWidgets('ProgressHeader exibe label da medalha Gold para 75%',
      (tester) async {
    final achievements = List.generate(
      4,
      (i) => Achievement(
          id: '$i', gameId: 'g1', title: 'A$i', isUnlocked: i < 3),
    );
    await tester.pumpWidget(_wrap(ProgressHeader(achievements: achievements)));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Ouro'), findsOneWidget);
  });
}
