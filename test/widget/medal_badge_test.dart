import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/core/theme/app_theme.dart';
import 'package:game_achievements/domain/entities/medal_tier.dart';
import 'package:game_achievements/presentation/home/widgets/medal_badge.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('MedalBadge none não renderiza nenhum Container', (tester) async {
    await tester.pumpWidget(_wrap(const MedalBadge(tier: MedalTier.none)));
    expect(find.byType(Container), findsNothing);
  });

  testWidgets('MedalBadge diamond exibe ícone de diamante', (tester) async {
    await tester.pumpWidget(_wrap(const MedalBadge(tier: MedalTier.diamond)));
    await tester.pump(const Duration(milliseconds: 1900)); // conclui shimmer de 1800ms
    expect(find.byIcon(Icons.diamond_rounded), findsOneWidget);
  });

  testWidgets('MedalBadge gold exibe ícone military_tech', (tester) async {
    await tester.pumpWidget(_wrap(const MedalBadge(tier: MedalTier.gold)));
    await tester.pump();
    expect(find.byIcon(Icons.military_tech_rounded), findsOneWidget);
  });

  testWidgets('MedalBadge bronze exibe ícone emoji_events', (tester) async {
    await tester.pumpWidget(_wrap(const MedalBadge(tier: MedalTier.bronze)));
    await tester.pump();
    expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
  });
}
