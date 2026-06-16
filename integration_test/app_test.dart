import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game_achievements/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Fluxo completo de navegação entre telas', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Home screen está visível (bottom nav presente)
    expect(find.byType(NavigationBar), findsOneWidget);

    // Navegar para Perfil
    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Perfil'), findsOneWidget);

    // Navegar para Configurações
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Configurações'), findsOneWidget);

    // Voltar para Home
    await tester.tap(find.byIcon(Icons.sports_esports_rounded));
    await tester.pumpAndSettle();

    // Abrir sheet de adicionar game (FAB)
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Adicionar Game'), findsOneWidget);

    // Fechar a sheet tocando fora
    await tester.tapAt(const Offset(400, 100));
    await tester.pumpAndSettle();

    // Sheet fechada, home visível novamente
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
