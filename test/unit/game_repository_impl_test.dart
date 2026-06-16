import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:game_achievements/data/datasources/local/game_local_datasource.dart';
import 'package:game_achievements/data/repositories/game_repository_impl.dart';
import 'package:game_achievements/domain/entities/game.dart';

// Mock null-safe manual para classe concreta (sem build_runner)
class MockGameLocalDatasource extends Mock implements GameLocalDatasource {
  @override
  Future<List<Game>> getAll() => super.noSuchMethod(
        Invocation.method(#getAll, []),
        returnValue: Future<List<Game>>.value([]),
      ) as Future<List<Game>>;

  @override
  Future<Game?> getById(String id) => super.noSuchMethod(
        Invocation.method(#getById, [id]),
        returnValue: Future<Game?>.value(),
      ) as Future<Game?>;

  @override
  Future<void> insert(Game game) => super.noSuchMethod(
        Invocation.method(#insert, [game]),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> update(Game game) => super.noSuchMethod(
        Invocation.method(#update, [game]),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> delete(String id) => super.noSuchMethod(
        Invocation.method(#delete, [id]),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> reorder(List<String> orderedIds) => super.noSuchMethod(
        Invocation.method(#reorder, [orderedIds]),
        returnValue: Future<void>.value(),
      ) as Future<void>;
}

void main() {
  late MockGameLocalDatasource mockDatasource;
  late GameRepositoryImpl repository;

  final fakeGame = Game(
    id: 'abc-123',
    title: 'Elden Ring',
    totalAchievements: 10,
    unlockedAchievements: 5,
    sortOrder: 0,
    addedAt: DateTime(2024),
  );

  setUp(() {
    mockDatasource = MockGameLocalDatasource();
    repository = GameRepositoryImpl(mockDatasource);
  });

  test('getAllGames delega para datasource.getAll', () async {
    when(mockDatasource.getAll()).thenAnswer((_) async => [fakeGame]);
    final result = await repository.getAllGames();
    expect(result, [fakeGame]);
    verify(mockDatasource.getAll()).called(1);
  });

  test('saveGame delega para datasource.insert', () async {
    when(mockDatasource.insert(fakeGame)).thenAnswer((_) async {});
    await repository.saveGame(fakeGame);
    verify(mockDatasource.insert(fakeGame)).called(1);
  });

  test('deleteGame delega para datasource.delete', () async {
    when(mockDatasource.delete('abc-123')).thenAnswer((_) async {});
    await repository.deleteGame('abc-123');
    verify(mockDatasource.delete('abc-123')).called(1);
  });

  test('reorderGames delega para datasource.reorder', () async {
    final ids = ['b', 'a'];
    when(mockDatasource.reorder(ids)).thenAnswer((_) async {});
    await repository.reorderGames(ids);
    verify(mockDatasource.reorder(ids)).called(1);
  });

  test('getGameById delega para datasource.getById', () async {
    when(mockDatasource.getById('abc-123')).thenAnswer((_) async => fakeGame);
    final result = await repository.getGameById('abc-123');
    expect(result, fakeGame);
    verify(mockDatasource.getById('abc-123')).called(1);
  });
}
