import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/data/models/rawg_game_model.dart';

void main() {
  group('RawgGame.fromJson', () {
    test('parseia todos os campos preenchidos', () {
      final json = {
        'id': 42,
        'name': 'The Witcher 3',
        'background_image': 'https://example.com/img.jpg',
        'description_raw': 'Uma obra prima.',
        'rating': 4.7,
      };
      final model = RawgGame.fromJson(json);
      expect(model.id, 42);
      expect(model.name, 'The Witcher 3');
      expect(model.backgroundImage, 'https://example.com/img.jpg');
      expect(model.description, 'Uma obra prima.');
      expect(model.rating, 4.7);
    });

    test('aceita campos opcionais nulos', () {
      final json = {'id': 1, 'name': 'Game Sem Capa'};
      final model = RawgGame.fromJson(json);
      expect(model.id, 1);
      expect(model.name, 'Game Sem Capa');
      expect(model.backgroundImage, isNull);
      expect(model.description, isNull);
      expect(model.rating, isNull);
    });

    test('converte rating de int para double', () {
      final json = {'id': 2, 'name': 'Game', 'rating': 4};
      final model = RawgGame.fromJson(json);
      expect(model.rating, 4.0);
      expect(model.rating, isA<double>());
    });
  });
}
