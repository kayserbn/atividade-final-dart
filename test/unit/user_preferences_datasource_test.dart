import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game_achievements/data/datasources/preferences/user_preferences_datasource.dart';
import 'package:game_achievements/domain/entities/user_profile.dart';

void main() {
  late UserPreferencesDatasource datasource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    datasource = UserPreferencesDatasource();
  });

  test('retorna null quando não há perfil salvo', () async {
    final profile = await datasource.getProfile();
    expect(profile, isNull);
  });

  test('salva e recupera nickname corretamente', () async {
    final profile = UserProfile(
      nickname: 'Kayser',
      createdAt: DateTime(2024, 6, 16),
    );
    await datasource.saveProfile(profile);

    final recovered = await datasource.getProfile();
    expect(recovered, isNotNull);
    expect(recovered!.nickname, 'Kayser');
  });

  test('salva e recupera avatarPath corretamente', () async {
    final profile = UserProfile(
      nickname: 'Jogador',
      avatarPath: '/storage/img.jpg',
      createdAt: DateTime(2024),
    );
    await datasource.saveProfile(profile);

    final recovered = await datasource.getProfile();
    expect(recovered!.avatarPath, '/storage/img.jpg');
  });

  test('isGridView retorna false por padrão', () async {
    expect(await datasource.isGridView(), isFalse);
  });

  test('setGridView persiste e recupera preferência corretamente', () async {
    await datasource.setGridView(true);
    expect(await datasource.isGridView(), isTrue);

    await datasource.setGridView(false);
    expect(await datasource.isGridView(), isFalse);
  });
}
