import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/main.dart';

void main() {
  testWidgets('App smoke test — renderiza sem erros', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: GameAchievementsApp()),
    );
    await tester.pump();
    expect(find.text('Game Achievements'), findsOneWidget);
  });
}
