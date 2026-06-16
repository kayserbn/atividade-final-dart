# Guia de Desenvolvimento — Game Achievements App (Flutter)

> App local de conquistas de games. Roda no emulador Pixel 4.
> Estética: roxo escuro + ciano/azul claro, branco e preto. Moderno e minimalista com animações caprichadas.

---

## Sumário

1. [Pré-requisitos](#1-pré-requisitos)
2. [Criar o Projeto](#2-criar-o-projeto)
3. [pubspec.yaml — dependências](#3-pubspecyaml--dependências)
4. [Estrutura de Pastas (Clean Architecture)](#4-estrutura-de-pastas-clean-architecture)
5. [Tema e Design System](#5-tema-e-design-system)
6. [Domain Layer — Entidades e Contratos](#6-domain-layer--entidades-e-contratos)
7. [Data Layer — SQLite (sqflite)](#7-data-layer--sqlite-sqflite)
8. [Data Layer — SharedPreferences](#8-data-layer--sharedpreferences)
9. [Data Layer — Dio (RAWG API)](#9-data-layer--dio-rawg-api)
10. [Providers Riverpod](#10-providers-riverpod)
11. [GoRouter — Navegação com parâmetros](#11-gorouter--navegação-com-parâmetros)
12. [Home Screen](#12-home-screen)
13. [Game Detail Screen](#13-game-detail-screen)
14. [Profile Screen](#14-profile-screen)
15. [Settings Screen](#15-settings-screen)
16. [Animações com flutter_animate](#16-animações-com-flutter_animate)
17. [Testes](#17-testes)
18. [Rodar no Emulador Pixel 4](#18-rodar-no-emulador-pixel-4)

---

## 1. Pré-requisitos

- Flutter SDK >= 3.22 (`flutter --version`)
- Android Studio com emulador Pixel 4 criado (API 34 recomendado)
- VS Code ou Android Studio como IDE
- Dart SDK incluído no Flutter
- Conta gratuita na RAWG para obter a API key: https://rawg.io/apidocs

Verificar o ambiente:
```bash
flutter doctor
flutter emulators        # listar emuladores disponíveis
flutter emulators --launch <id_do_pixel_4>
```

---

## 2. Criar o Projeto

```bash
# Criar na pasta desejada
flutter create --org com.gameachievements --project-name game_achievements game_achievements
cd game_achievements

# Abrir no emulador Pixel 4
flutter run -d pixel_4
```

> **packageId:** `com.gameachievements.game_achievements`

---

## 3. pubspec.yaml — dependências

Substituir o bloco `dependencies` e `dev_dependencies` pelo seguinte:

```yaml
name: game_achievements
description: App local de conquistas de games
publish_to: none
version: 1.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # Navegação
  go_router: ^14.8.1

  # HTTP / API
  dio: ^5.7.0

  # Persistência simples
  shared_preferences: ^2.3.3

  # SQLite
  sqflite: ^2.3.3+1
  path: ^1.9.0

  # Fontes e UI
  google_fonts: ^6.3.0
  flutter_animate: ^4.5.2
  cached_network_image: ^3.4.1

  # Utilidades
  uuid: ^4.5.1
  equatable: ^2.0.7
  image_picker: ^1.1.2
  path_provider: ^2.1.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  riverpod_generator: ^2.6.1
  build_runner: ^2.4.13
  mockito: ^5.4.4
  build_runner: ^2.4.13

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

Depois rodar:
```bash
flutter pub get
mkdir -p assets/images assets/icons
```

---

## 4. Estrutura de Pastas (Clean Architecture)

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # paleta de cores
│   │   ├── app_typography.dart    # fontes e estilos
│   │   └── app_constants.dart     # strings, valores fixos
│   ├── errors/
│   │   └── failures.dart          # classes de falha
│   ├── extensions/
│   │   └── string_extensions.dart
│   └── theme/
│       └── app_theme.dart         # ThemeData completo
│
├── domain/
│   ├── entities/
│   │   ├── game.dart
│   │   ├── achievement.dart
│   │   ├── user_profile.dart
│   │   └── medal_tier.dart        # enum
│   ├── repositories/
│   │   ├── game_repository.dart         # abstract
│   │   ├── achievement_repository.dart  # abstract
│   │   └── user_repository.dart         # abstract
│   └── usecases/
│       ├── get_games_usecase.dart
│       ├── save_game_usecase.dart
│       ├── get_achievements_usecase.dart
│       ├── update_user_profile_usecase.dart
│       └── search_games_api_usecase.dart
│
├── data/
│   ├── database/
│   │   ├── database_helper.dart   # SQLite setup + migrations
│   │   └── dao/
│   │       ├── game_dao.dart
│   │       └── achievement_dao.dart
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── game_local_datasource.dart
│   │   │   └── achievement_local_datasource.dart
│   │   ├── preferences/
│   │   │   └── user_preferences_datasource.dart  # SharedPreferences
│   │   └── remote/
│   │       └── rawg_api_datasource.dart           # Dio
│   ├── models/
│   │   ├── game_model.dart
│   │   ├── achievement_model.dart
│   │   └── rawg_game_model.dart   # DTO da API
│   └── repositories/
│       ├── game_repository_impl.dart
│       ├── achievement_repository_impl.dart
│       └── user_repository_impl.dart
│
└── presentation/
    ├── providers/
    │   ├── game_provider.dart
    │   ├── achievement_provider.dart
    │   ├── user_provider.dart
    │   └── search_provider.dart
    ├── router/
    │   └── app_router.dart
    ├── home/
    │   ├── home_screen.dart
    │   └── widgets/
    │       ├── game_card.dart
    │       ├── game_grid_item.dart
    │       ├── medal_badge.dart
    │       └── home_header.dart
    ├── game_detail/
    │   ├── game_detail_screen.dart
    │   └── widgets/
    │       ├── achievement_tile.dart
    │       └── progress_header.dart
    ├── profile/
    │   ├── profile_screen.dart
    │   └── widgets/
    │       ├── profile_avatar.dart
    │       └── diamond_showcase.dart
    └── settings/
        ├── settings_screen.dart
        └── widgets/
            └── reorderable_game_list.dart
```

Criar todos os diretórios:
```bash
mkdir -p lib/{core/{constants,errors,extensions,theme},domain/{entities,repositories,usecases},data/{database/dao,datasources/{local,preferences,remote},models,repositories},presentation/{providers,router,home/widgets,game_detail/widgets,profile/widgets,settings/widgets}}
```

---

## 5. Tema e Design System

### `lib/core/constants/app_colors.dart`
```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const background     = Color(0xFF0D0A1E);
  static const surface        = Color(0xFF1A1535);
  static const surfaceVariant = Color(0xFF231D42);
  static const card           = Color(0xFF1E1840);

  // Primary
  static const primary        = Color(0xFF7B2FBE);
  static const primaryLight   = Color(0xFF9D4EDD);
  static const primaryDark    = Color(0xFF5A1A94);

  // Accent
  static const accent         = Color(0xFF00E5FF);
  static const accentSoft     = Color(0xFF00B8D9);

  // Texto
  static const textPrimary    = Color(0xFFFFFFFF);
  static const textSecondary  = Color(0xFFB0A8C8);
  static const textMuted      = Color(0xFF6B6280);

  // Medals
  static const bronze  = Color(0xFFCD7F32);
  static const silver  = Color(0xFFC0C0C0);
  static const gold    = Color(0xFFFFD700);
  static const diamond = Color(0xFF00E5FF); // mesmo que accent

  // Status
  static const success = Color(0xFF00E676);
  static const error   = Color(0xFFFF5252);
}
```

### `lib/core/constants/app_typography.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static TextTheme get textTheme => TextTheme(
    displayLarge:  GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    displayMedium: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    headlineLarge: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    headlineMedium:GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    titleLarge:    GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    titleMedium:   GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    bodyLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
    bodyMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
    bodySmall:     GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted),
    labelLarge:    GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.8),
  );
}
```

### `lib/core/theme/app_theme.dart`
```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

final class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      background:    AppColors.background,
      surface:       AppColors.surface,
      primary:       AppColors.primary,
      secondary:     AppColors.accent,
      onBackground:  AppColors.textPrimary,
      onSurface:     AppColors.textPrimary,
      onPrimary:     AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: AppTypography.textTheme,
    cardTheme: const CardTheme(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.surfaceVariant, thickness: 1),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textMuted,
    ),
  );
}
```

---

## 6. Domain Layer — Entidades e Contratos

### `lib/domain/entities/medal_tier.dart`
```dart
enum MedalTier { none, bronze, silver, gold, diamond }

extension MedalTierExtension on MedalTier {
  // Baseado no percentual de conquistas desbloqueadas
  static MedalTier fromPercentage(double percent) {
    if (percent >= 100) return MedalTier.diamond;
    if (percent >= 75)  return MedalTier.gold;
    if (percent >= 50)  return MedalTier.silver;
    if (percent >= 25)  return MedalTier.bronze;
    return MedalTier.none;
  }

  String get label => switch (this) {
    MedalTier.none    => 'Sem medalha',
    MedalTier.bronze  => 'Bronze',
    MedalTier.silver  => 'Prata',
    MedalTier.gold    => 'Ouro',
    MedalTier.diamond => 'Diamante',
  };
}
```

### `lib/domain/entities/game.dart`
```dart
import 'package:equatable/equatable.dart';
import 'medal_tier.dart';

class Game extends Equatable {
  final String id;
  final String title;
  final String? coverImagePath;    // caminho local ou URL
  final String? description;
  final int    totalAchievements;
  final int    unlockedAchievements;
  final int    sortOrder;
  final DateTime addedAt;

  const Game({
    required this.id,
    required this.title,
    this.coverImagePath,
    this.description,
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.sortOrder,
    required this.addedAt,
  });

  double get completionPercentage =>
      totalAchievements == 0 ? 0 : (unlockedAchievements / totalAchievements) * 100;

  MedalTier get medalTier =>
      MedalTierExtension.fromPercentage(completionPercentage);

  Game copyWith({
    String? title,
    String? coverImagePath,
    String? description,
    int? totalAchievements,
    int? unlockedAchievements,
    int? sortOrder,
  }) => Game(
    id: id,
    title: title ?? this.title,
    coverImagePath: coverImagePath ?? this.coverImagePath,
    description: description ?? this.description,
    totalAchievements: totalAchievements ?? this.totalAchievements,
    unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    sortOrder: sortOrder ?? this.sortOrder,
    addedAt: addedAt,
  );

  @override
  List<Object?> get props => [id, title, coverImagePath, description,
      totalAchievements, unlockedAchievements, sortOrder, addedAt];
}
```

### `lib/domain/entities/achievement.dart`
```dart
import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String gameId;
  final String title;
  final String? description;
  final String? iconPath;
  final bool   isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.gameId,
    required this.title,
    this.description,
    this.iconPath,
    required this.isUnlocked,
    this.unlockedAt,
  });

  Achievement copyWith({bool? isUnlocked, DateTime? unlockedAt}) => Achievement(
    id: id, gameId: gameId, title: title,
    description: description, iconPath: iconPath,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );

  @override
  List<Object?> get props => [id, gameId, title, description, iconPath, isUnlocked, unlockedAt];
}
```

### `lib/domain/entities/user_profile.dart`
```dart
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String nickname;
  final String? avatarPath;
  final DateTime createdAt;

  const UserProfile({
    required this.nickname,
    this.avatarPath,
    required this.createdAt,
  });

  UserProfile copyWith({String? nickname, String? avatarPath}) => UserProfile(
    nickname: nickname ?? this.nickname,
    avatarPath: avatarPath ?? this.avatarPath,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [nickname, avatarPath, createdAt];
}
```

### `lib/domain/repositories/game_repository.dart`
```dart
import '../entities/game.dart';

abstract interface class GameRepository {
  Future<List<Game>> getAllGames();
  Future<Game?> getGameById(String id);
  Future<void> saveGame(Game game);
  Future<void> updateGame(Game game);
  Future<void> deleteGame(String id);
  Future<void> reorderGames(List<String> orderedIds);
}
```

### `lib/domain/repositories/achievement_repository.dart`
```dart
import '../entities/achievement.dart';

abstract interface class AchievementRepository {
  Future<List<Achievement>> getAchievementsByGame(String gameId);
  Future<void> saveAchievement(Achievement achievement);
  Future<void> toggleAchievement(String id, bool isUnlocked);
  Future<void> deleteAchievementsByGame(String gameId);
}
```

### `lib/domain/repositories/user_repository.dart`
```dart
import '../entities/user_profile.dart';

abstract interface class UserRepository {
  Future<UserProfile?> getProfile();
  Future<void> saveProfile(UserProfile profile);
}
```

---

## 7. Data Layer — SQLite (sqflite)

### `lib/data/database/database_helper.dart`
```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'game_achievements.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE games (
        id              TEXT PRIMARY KEY,
        title           TEXT NOT NULL,
        cover_image_path TEXT,
        description     TEXT,
        sort_order      INTEGER NOT NULL DEFAULT 0,
        added_at        TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id          TEXT PRIMARY KEY,
        game_id     TEXT NOT NULL,
        title       TEXT NOT NULL,
        description TEXT,
        icon_path   TEXT,
        is_unlocked INTEGER NOT NULL DEFAULT 0,
        unlocked_at TEXT,
        FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE
      )
    ''');
  }
}
```

### `lib/data/models/game_model.dart`
```dart
import '../../domain/entities/game.dart';

class GameModel {
  final String id;
  final String title;
  final String? coverImagePath;
  final String? description;
  final int sortOrder;
  final String addedAt;
  // totalAchievements e unlockedAchievements são calculados via JOIN ou query separada

  const GameModel({
    required this.id,
    required this.title,
    this.coverImagePath,
    this.description,
    required this.sortOrder,
    required this.addedAt,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) => GameModel(
    id: map['id'] as String,
    title: map['title'] as String,
    coverImagePath: map['cover_image_path'] as String?,
    description: map['description'] as String?,
    sortOrder: map['sort_order'] as int,
    addedAt: map['added_at'] as String,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'cover_image_path': coverImagePath,
    'description': description,
    'sort_order': sortOrder,
    'added_at': addedAt,
  };

  Game toEntity({int total = 0, int unlocked = 0}) => Game(
    id: id,
    title: title,
    coverImagePath: coverImagePath,
    description: description,
    totalAchievements: total,
    unlockedAchievements: unlocked,
    sortOrder: sortOrder,
    addedAt: DateTime.parse(addedAt),
  );
}
```

### `lib/data/models/achievement_model.dart`
```dart
import '../../domain/entities/achievement.dart';

class AchievementModel {
  final String id;
  final String gameId;
  final String title;
  final String? description;
  final String? iconPath;
  final int isUnlocked;
  final String? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.gameId,
    required this.title,
    this.description,
    this.iconPath,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory AchievementModel.fromMap(Map<String, dynamic> map) => AchievementModel(
    id: map['id'] as String,
    gameId: map['game_id'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    iconPath: map['icon_path'] as String?,
    isUnlocked: map['is_unlocked'] as int,
    unlockedAt: map['unlocked_at'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'game_id': gameId,
    'title': title,
    'description': description,
    'icon_path': iconPath,
    'is_unlocked': isUnlocked,
    'unlocked_at': unlockedAt,
  };

  Achievement toEntity() => Achievement(
    id: id,
    gameId: gameId,
    title: title,
    description: description,
    iconPath: iconPath,
    isUnlocked: isUnlocked == 1,
    unlockedAt: unlockedAt != null ? DateTime.parse(unlockedAt!) : null,
  );

  factory AchievementModel.fromEntity(Achievement a) => AchievementModel(
    id: a.id,
    gameId: a.gameId,
    title: a.title,
    description: a.description,
    iconPath: a.iconPath,
    isUnlocked: a.isUnlocked ? 1 : 0,
    unlockedAt: a.unlockedAt?.toIso8601String(),
  );
}
```

### `lib/data/datasources/local/game_local_datasource.dart`
```dart
import 'package:sqflite/sqflite.dart';
import '../../database/database_helper.dart';
import '../../models/game_model.dart';
import '../../../domain/entities/game.dart';

class GameLocalDatasource {
  final DatabaseHelper _dbHelper;
  GameLocalDatasource(this._dbHelper);

  Future<List<Game>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT g.*,
        COUNT(a.id)                          AS total_achievements,
        SUM(CASE WHEN a.is_unlocked = 1 THEN 1 ELSE 0 END) AS unlocked_achievements
      FROM games g
      LEFT JOIN achievements a ON a.game_id = g.id
      GROUP BY g.id
      ORDER BY g.sort_order ASC
    ''');
    return rows.map((r) {
      final model = GameModel.fromMap(r);
      return model.toEntity(
        total:    (r['total_achievements'] as int?) ?? 0,
        unlocked: (r['unlocked_achievements'] as int?) ?? 0,
      );
    }).toList();
  }

  Future<Game?> getById(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT g.*,
        COUNT(a.id) AS total_achievements,
        SUM(CASE WHEN a.is_unlocked = 1 THEN 1 ELSE 0 END) AS unlocked_achievements
      FROM games g
      LEFT JOIN achievements a ON a.game_id = g.id
      WHERE g.id = ?
      GROUP BY g.id
    ''', [id]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return GameModel.fromMap(r).toEntity(
      total:    (r['total_achievements'] as int?) ?? 0,
      unlocked: (r['unlocked_achievements'] as int?) ?? 0,
    );
  }

  Future<void> insert(Game game) async {
    final db = await _dbHelper.database;
    final model = GameModel(
      id: game.id,
      title: game.title,
      coverImagePath: game.coverImagePath,
      description: game.description,
      sortOrder: game.sortOrder,
      addedAt: game.addedAt.toIso8601String(),
    );
    await db.insert('games', model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Game game) async {
    final db = await _dbHelper.database;
    await db.update(
      'games',
      {
        'title': game.title,
        'cover_image_path': game.coverImagePath,
        'description': game.description,
        'sort_order': game.sortOrder,
      },
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> reorder(List<String> orderedIds) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (var i = 0; i < orderedIds.length; i++) {
        await txn.update(
          'games',
          {'sort_order': i},
          where: 'id = ?',
          whereArgs: [orderedIds[i]],
        );
      }
    });
  }
}
```

### `lib/data/datasources/local/achievement_local_datasource.dart`
```dart
import 'package:sqflite/sqflite.dart';
import '../../database/database_helper.dart';
import '../../models/achievement_model.dart';
import '../../../domain/entities/achievement.dart';

class AchievementLocalDatasource {
  final DatabaseHelper _dbHelper;
  AchievementLocalDatasource(this._dbHelper);

  Future<List<Achievement>> getByGame(String gameId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('achievements',
        where: 'game_id = ?', whereArgs: [gameId]);
    return rows.map((r) => AchievementModel.fromMap(r).toEntity()).toList();
  }

  Future<void> insert(Achievement achievement) async {
    final db = await _dbHelper.database;
    await db.insert('achievements', AchievementModel.fromEntity(achievement).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> toggle(String id, bool isUnlocked) async {
    final db = await _dbHelper.database;
    await db.update(
      'achievements',
      {
        'is_unlocked': isUnlocked ? 1 : 0,
        'unlocked_at': isUnlocked ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByGame(String gameId) async {
    final db = await _dbHelper.database;
    await db.delete('achievements', where: 'game_id = ?', whereArgs: [gameId]);
  }
}
```

### Implementações de repositório

### `lib/data/repositories/game_repository_impl.dart`
```dart
import '../../domain/entities/game.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local/game_local_datasource.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLocalDatasource _local;
  GameRepositoryImpl(this._local);

  @override Future<List<Game>> getAllGames()         => _local.getAll();
  @override Future<Game?> getGameById(String id)    => _local.getById(id);
  @override Future<void> saveGame(Game game)        => _local.insert(game);
  @override Future<void> updateGame(Game game)      => _local.update(game);
  @override Future<void> deleteGame(String id)      => _local.delete(id);
  @override Future<void> reorderGames(List<String> ids) => _local.reorder(ids);
}
```

---

## 8. Data Layer — SharedPreferences

### `lib/data/datasources/preferences/user_preferences_datasource.dart`
```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/user_profile.dart';

class UserPreferencesDatasource {
  static const _keyNickname  = 'user_nickname';
  static const _keyAvatar    = 'user_avatar_path';
  static const _keyCreatedAt = 'user_created_at';
  static const _keyGridView  = 'home_grid_view';

  Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final nickname = prefs.getString(_keyNickname);
    if (nickname == null) return null;
    return UserProfile(
      nickname: nickname,
      avatarPath: prefs.getString(_keyAvatar),
      createdAt: DateTime.parse(
        prefs.getString(_keyCreatedAt) ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNickname, profile.nickname);
    if (profile.avatarPath != null) {
      await prefs.setString(_keyAvatar, profile.avatarPath!);
    }
    await prefs.setString(_keyCreatedAt, profile.createdAt.toIso8601String());
  }

  // Preferência de layout (lista ou grade)
  Future<bool> isGridView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGridView) ?? false;
  }

  Future<void> setGridView(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGridView, value);
  }
}
```

---

## 9. Data Layer — Dio (RAWG API)

> **RAWG API** é gratuita e perfeita para buscar dados de games.
> Cadastre-se em https://rawg.io/apidocs para obter sua `apiKey`.
> Guarde a chave em `lib/core/constants/app_constants.dart` — **nunca** commite em repositórios públicos.

### `lib/core/constants/app_constants.dart`
```dart
abstract final class AppConstants {
  // Substitua pela sua chave RAWG — não commite chaves reais em repositórios públicos
  static const rawgApiKey     = 'SUA_CHAVE_AQUI';
  static const rawgBaseUrl    = 'https://api.rawg.io/api';
  static const pageSize       = 20;
}
```

### `lib/data/models/rawg_game_model.dart`
```dart
class RawgGame {
  final int    id;
  final String name;
  final String? backgroundImage;
  final String? description;
  final double? rating;

  const RawgGame({
    required this.id,
    required this.name,
    this.backgroundImage,
    this.description,
    this.rating,
  });

  factory RawgGame.fromJson(Map<String, dynamic> json) => RawgGame(
    id:              json['id'] as int,
    name:            json['name'] as String,
    backgroundImage: json['background_image'] as String?,
    description:     json['description_raw'] as String?,
    rating:          (json['rating'] as num?)?.toDouble(),
  );
}
```

### `lib/data/datasources/remote/rawg_api_datasource.dart`
```dart
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/rawg_game_model.dart';

class RawgApiDatasource {
  late final Dio _dio;

  RawgApiDatasource() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.rawgBaseUrl,
      queryParameters: {'key': AppConstants.rawgApiKey},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _dio.interceptors.add(LogInterceptor(responseBody: false));
  }

  Future<List<RawgGame>> searchGames(String query, {int page = 1}) async {
    final response = await _dio.get('/games', queryParameters: {
      'search': query,
      'page':   page,
      'page_size': AppConstants.pageSize,
    });
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((e) => RawgGame.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RawgGame> getGameDetail(int rawgId) async {
    final response = await _dio.get('/games/$rawgId');
    return RawgGame.fromJson(response.data as Map<String, dynamic>);
  }
}
```

---

## 10. Providers Riverpod

### `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: GameAchievementsApp()));
}

class GameAchievementsApp extends ConsumerWidget {
  const GameAchievementsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Game Achievements',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### `lib/presentation/providers/game_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database_helper.dart';
import '../../data/datasources/local/game_local_datasource.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/entities/game.dart';
import '../../domain/repositories/game_repository.dart';

// Infraestrutura
final databaseHelperProvider = Provider<DatabaseHelper>(
  (_) => DatabaseHelper.instance,
  dependencies: [],
);

final gameLocalDatasourceProvider = Provider<GameLocalDatasource>(
  (ref) => GameLocalDatasource(ref.watch(databaseHelperProvider)),
);

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepositoryImpl(ref.watch(gameLocalDatasourceProvider)),
);

// Estado dos games
class GamesNotifier extends AsyncNotifier<List<Game>> {
  @override
  Future<List<Game>> build() => ref.watch(gameRepositoryProvider).getAllGames();

  Future<void> addGame(Game game) async {
    await ref.read(gameRepositoryProvider).saveGame(game);
    ref.invalidateSelf();
  }

  Future<void> updateGame(Game game) async {
    await ref.read(gameRepositoryProvider).updateGame(game);
    ref.invalidateSelf();
  }

  Future<void> deleteGame(String id) async {
    await ref.read(gameRepositoryProvider).deleteGame(id);
    ref.invalidateSelf();
  }

  Future<void> reorder(List<String> orderedIds) async {
    await ref.read(gameRepositoryProvider).reorderGames(orderedIds);
    ref.invalidateSelf();
  }
}

final gamesProvider = AsyncNotifierProvider<GamesNotifier, List<Game>>(
  GamesNotifier.new,
);
```

### `lib/presentation/providers/achievement_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/achievement_local_datasource.dart';
import '../../data/repositories/achievement_repository_impl.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';
import 'game_provider.dart';

final achievementLocalDatasourceProvider = Provider<AchievementLocalDatasource>(
  (ref) => AchievementLocalDatasource(ref.watch(databaseHelperProvider)),
);

final achievementRepositoryProvider = Provider<AchievementRepository>(
  (ref) => AchievementRepositoryImpl(ref.watch(achievementLocalDatasourceProvider)),
);

// Conquistas por game (parametrizado)
final achievementsProvider = FutureProvider.family<List<Achievement>, String>(
  (ref, gameId) =>
      ref.watch(achievementRepositoryProvider).getAchievementsByGame(gameId),
);

class AchievementsNotifier extends FamilyAsyncNotifier<List<Achievement>, String> {
  @override
  Future<List<Achievement>> build(String arg) =>
      ref.watch(achievementRepositoryProvider).getAchievementsByGame(arg);

  Future<void> toggle(String achievementId, bool unlocked) async {
    await ref.read(achievementRepositoryProvider).toggleAchievement(achievementId, unlocked);
    ref.invalidateSelf();
    ref.invalidate(gamesProvider); // atualiza % na home
  }
}

final achievementsNotifierProvider =
    AsyncNotifierProviderFamily<AchievementsNotifier, List<Achievement>, String>(
  AchievementsNotifier.new,
);
```

### `lib/presentation/providers/user_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/preferences/user_preferences_datasource.dart';
import '../../domain/entities/user_profile.dart';

final userPreferencesDatasourceProvider = Provider<UserPreferencesDatasource>(
  (_) => UserPreferencesDatasource(),
);

class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() =>
      ref.watch(userPreferencesDatasourceProvider).getProfile();

  Future<void> save(UserProfile profile) async {
    await ref.read(userPreferencesDatasourceProvider).saveProfile(profile);
    ref.invalidateSelf();
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile?>(
  UserProfileNotifier.new,
);

// Layout preference
class GridViewNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.watch(userPreferencesDatasourceProvider).isGridView();

  Future<void> toggle() async {
    final current = state.valueOrNull ?? false;
    await ref.read(userPreferencesDatasourceProvider).setGridView(!current);
    ref.invalidateSelf();
  }
}

final gridViewProvider = AsyncNotifierProvider<GridViewNotifier, bool>(
  GridViewNotifier.new,
);
```

### `lib/presentation/providers/search_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/rawg_api_datasource.dart';
import '../../data/models/rawg_game_model.dart';

final rawgApiDatasourceProvider = Provider<RawgApiDatasource>(
  (_) => RawgApiDatasource(),
);

// Provider parametrizado por query de busca
final rawgSearchProvider = FutureProvider.family<List<RawgGame>, String>(
  (ref, query) {
    if (query.isEmpty) return Future.value([]);
    return ref.watch(rawgApiDatasourceProvider).searchGames(query);
  },
);
```

---

## 11. GoRouter — Navegação com parâmetros

### `lib/presentation/router/app_router.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../home/home_screen.dart';
import '../game_detail/game_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

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
      // Rota fora do shell (sem bottom nav)
      GoRoute(
        path: '/game/:id',
        name: 'game-detail',
        builder: (context, state) {
          final gameId = state.pathParameters['id']!;
          // extra pode trazer o título para o AppBar sem esperar o async
          final gameTitle = state.extra as String? ?? '';
          return GameDetailScreen(gameId: gameId, gameTitle: gameTitle);
        },
      ),
    ],
  );
});

// Shell com BottomNavigationBar
class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    final tabs = [('/', Icons.sports_esports_rounded, 'Games'),
                  ('/profile', Icons.person_rounded, 'Perfil'),
                  ('/settings', Icons.tune_rounded, 'Config')];

    int currentIndex = tabs.indexWhere((t) => location == t.$1);
    if (currentIndex < 0) currentIndex = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(tabs[i].$1),
        destinations: tabs.map((t) => NavigationDestination(
          icon: Icon(t.$2), label: t.$3,
        )).toList(),
      ),
    );
  }
}
```

Como navegar com parâmetros:
```dart
// Navegar para detalhes passando id e título como extra
context.pushNamed('game-detail',
  pathParameters: {'id': game.id},
  extra: game.title,
);
```

---

## 12. Home Screen

### `lib/presentation/home/home_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/game_card.dart';
import 'widgets/game_grid_item.dart';
import 'widgets/home_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync   = ref.watch(gamesProvider);
    final isGridAsync  = ref.watch(gridViewProvider);
    final isGrid       = isGridAsync.valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const HomeHeader(),
        actions: [
          // Toggle lista/grade
          IconButton(
            icon: Icon(isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: AppColors.accent),
            onPressed: () => ref.read(gridViewProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.accent),
            onPressed: () => _showAddGameSheet(context, ref),
          ),
        ],
      ),
      body: gamesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (games) {
          if (games.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.sports_esports_outlined,
                    size: 80, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text('Nenhum game ainda',
                    style: Theme.of(context).textTheme.headlineMedium!
                        .copyWith(color: AppColors.textMuted)),
              ]).animate().fadeIn(duration: 500.ms),
            );
          }

          if (isGrid) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: games.length,
              itemBuilder: (ctx, i) => GameGridItem(game: games[i])
                  .animate(delay: (i * 60).ms)
                  .fadeIn()
                  .slideY(begin: 0.15),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: games.length,
            itemBuilder: (ctx, i) => GameCard(game: games[i])
                .animate(delay: (i * 60).ms)
                .fadeIn()
                .slideX(begin: 0.1),
          );
        },
      ),
    );
  }

  void _showAddGameSheet(BuildContext context, WidgetRef ref) {
    // Mostrar bottom sheet com busca RAWG + campo manual
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddGameSheet(),
    );
  }
}

// Sheet de adicionar game (com busca RAWG)
class _AddGameSheet extends ConsumerStatefulWidget {
  const _AddGameSheet();
  @override
  ConsumerState<_AddGameSheet> createState() => _AddGameSheetState();
}

class _AddGameSheetState extends ConsumerState<_AddGameSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(
      // importar search_provider
      // rawgSearchProvider(_query)
      // Por ora, placeholder
      Provider((_) => <dynamic>[]),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Buscar game na RAWG API...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}
```

### `lib/presentation/home/widgets/medal_badge.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/medal_tier.dart';

class MedalBadge extends StatelessWidget {
  final MedalTier tier;
  final double size;

  const MedalBadge({super.key, required this.tier, this.size = 24});

  @override
  Widget build(BuildContext context) {
    if (tier == MedalTier.none) return const SizedBox.shrink();

    final color = switch (tier) {
      MedalTier.bronze  => AppColors.bronze,
      MedalTier.silver  => AppColors.silver,
      MedalTier.gold    => AppColors.gold,
      MedalTier.diamond => AppColors.diamond,
      MedalTier.none    => Colors.transparent,
    };

    final icon = switch (tier) {
      MedalTier.diamond => Icons.diamond_rounded,
      MedalTier.gold    => Icons.military_tech_rounded,
      _                 => Icons.emoji_events_rounded,
    };

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(icon, color: color, size: size * 0.6),
    ).animate(
      onPlay: (c) => tier == MedalTier.diamond ? c.repeat() : null,
    ).shimmer(
      duration: 1800.ms,
      color: color.withOpacity(0.5),
      enabled: tier == MedalTier.diamond,
    );
  }
}
```

### `lib/presentation/home/widgets/game_card.dart`
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/game.dart';
import 'medal_badge.dart';

class GameCard extends StatelessWidget {
  final Game game;
  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed('game-detail',
          pathParameters: {'id': game.id}, extra: game.title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: game.medalTier == MedalTier.diamond
                ? AppColors.diamond.withOpacity(0.4)
                : AppColors.surfaceVariant,
            width: 1,
          ),
        ),
        child: Row(children: [
          // Cover
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: _buildCover(),
          ),
          // Infos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(game.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    MedalBadge(tier: game.medalTier),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    '${game.unlockedAchievements} / ${game.totalAchievements} conquistas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  // Barra de progresso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: game.completionPercentage / 100,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation(
                        _progressColor(game.completionPercentage),
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${game.completionPercentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall!
                        .copyWith(color: _progressColor(game.completionPercentage)),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ),
        ]),
      ),
    );
  }

  Widget _buildCover() {
    if (game.coverImagePath == null) {
      return Container(
        width: 90, height: 100,
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.sports_esports_rounded,
            color: AppColors.textMuted, size: 36),
      );
    }
    if (game.coverImagePath!.startsWith('http')) {
      return Image.network(game.coverImagePath!,
          width: 90, height: 100, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox(width: 90));
    }
    return Image.file(File(game.coverImagePath!),
        width: 90, height: 100, fit: BoxFit.cover);
  }

  Color _progressColor(double pct) {
    if (pct >= 100) return AppColors.diamond;
    if (pct >= 75)  return AppColors.gold;
    if (pct >= 50)  return AppColors.silver;
    if (pct >= 25)  return AppColors.bronze;
    return AppColors.textMuted;
  }
}
```

---

## 13. Game Detail Screen

### `lib/presentation/game_detail/game_detail_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../providers/achievement_provider.dart';
import 'widgets/achievement_tile.dart';
import 'widgets/progress_header.dart';

class GameDetailScreen extends ConsumerWidget {
  final String gameId;
  final String gameTitle;

  const GameDetailScreen({
    super.key,
    required this.gameId,
    required this.gameTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync =
        ref.watch(achievementsNotifierProvider(gameId));

    return Scaffold(
      appBar: AppBar(title: Text(gameTitle)),
      body: achievementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (achievements) => Column(children: [
          ProgressHeader(achievements: achievements),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: achievements.length,
              itemBuilder: (ctx, i) => AchievementTile(
                achievement: achievements[i],
                onToggle: (unlocked) => ref
                    .read(achievementsNotifierProvider(gameId).notifier)
                    .toggle(achievements[i].id, unlocked),
              ).animate(delay: (i * 40).ms).fadeIn().slideX(begin: 0.08),
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAchievementSheet(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Conquista'),
      ),
    );
  }

  void _showAddAchievementSheet(BuildContext context, WidgetRef ref) {
    // Bottom sheet para adicionar conquista
    // similar ao _AddGameSheet
  }
}
```

### `lib/presentation/game_detail/widgets/progress_header.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/achievement.dart';
import '../../../domain/entities/medal_tier.dart';
import '../../home/widgets/medal_badge.dart';

class ProgressHeader extends StatelessWidget {
  final List<Achievement> achievements;
  const ProgressHeader({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    final total    = achievements.length;
    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final pct      = total == 0 ? 0.0 : unlocked / total * 100;
    final tier     = MedalTierExtension.fromPercentage(pct);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tier == MedalTier.diamond
              ? AppColors.diamond.withOpacity(0.5)
              : AppColors.surfaceVariant,
        ),
      ),
      child: Row(children: [
        MedalBadge(tier: tier, size: 48),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$unlocked / $total conquistas',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: pct / 100),
                duration: 800.ms,
                builder: (_, value, __) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation(AppColors.accent),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('${pct.toStringAsFixed(0)}% — ${tier.label}',
                style: Theme.of(context).textTheme.bodySmall!
                    .copyWith(color: AppColors.accent)),
          ]),
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.97, 0.97));
  }
}
```

---

## 14. Profile Screen

### `lib/presentation/profile/profile_screen.dart`
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import '../../domain/entities/user_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final gamesAsync   = ref.watch(gamesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            // Avatar
            _AvatarSection(profile: profile).animate().fadeIn().scale(),
            const SizedBox(height: 32),
            // Nickname
            _NicknameSection(profile: profile),
            const SizedBox(height: 32),
            // Stats dos games
            gamesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (games) => _StatsSection(
                totalGames:       games.length,
                diamondGames:     games.where((g) => g.medalTier.index >= 4).length,
                completedGames:   games.where((g) => g.completionPercentage == 100).length,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _AvatarSection extends ConsumerWidget {
  final UserProfile? profile;
  const _AvatarSection({this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked == null) return;
        final updated = (profile ?? UserProfile(
              nickname: 'Jogador',
              createdAt: DateTime.now(),
            )).copyWith(avatarPath: picked.path);
        await ref.read(userProfileProvider.notifier).save(updated);
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: profile?.avatarPath != null
                ? FileImage(File(profile!.avatarPath!))
                : null,
            child: profile?.avatarPath == null
                ? const Icon(Icons.person_rounded,
                    size: 56, color: AppColors.textMuted)
                : null,
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt_rounded,
                size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _NicknameSection extends ConsumerStatefulWidget {
  final UserProfile? profile;
  const _NicknameSection({this.profile});
  @override
  ConsumerState<_NicknameSection> createState() => _NicknameSectionState();
}

class _NicknameSectionState extends ConsumerState<_NicknameSection> {
  late final TextEditingController _ctrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.profile?.nickname ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_editing)
          SizedBox(
            width: 200,
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          )
        else
          Text(widget.profile?.nickname ?? 'Jogador',
              style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            _editing ? Icons.check_rounded : Icons.edit_rounded,
            color: AppColors.accent,
          ),
          onPressed: () async {
            if (_editing) {
              final updated = (widget.profile ?? UserProfile(
                    nickname: _ctrl.text,
                    createdAt: DateTime.now(),
                  )).copyWith(nickname: _ctrl.text);
              await ref.read(userProfileProvider.notifier).save(updated);
            }
            setState(() => _editing = !_editing);
          },
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  final int totalGames;
  final int diamondGames;
  final int completedGames;

  const _StatsSection({
    required this.totalGames,
    required this.diamondGames,
    required this.completedGames,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _stat(context, '$totalGames', 'Games'),
        _stat(context, '$completedGames', '100%'),
        _stat(context, '$diamondGames', 'Diamante',
            color: AppColors.diamond),
      ],
    );
  }

  Widget _stat(BuildContext context, String value, String label,
      {Color? color}) =>
      Column(children: [
        Text(value,
            style: Theme.of(context).textTheme.displayMedium!
                .copyWith(color: color ?? AppColors.accent)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ]);
}
```

---

## 15. Settings Screen

### `lib/presentation/settings/settings_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/game_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(context, 'Reordenar Games'),
          gamesAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (games) => ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: games.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final reordered = [...games];
                final item = reordered.removeAt(oldIndex);
                reordered.insert(newIndex, item);
                ref.read(gamesProvider.notifier).reorder(
                  reordered.map((g) => g.id).toList(),
                );
              },
              itemBuilder: (ctx, i) => ListTile(
                key: ValueKey(games[i].id),
                leading: ReorderableDragStartListener(
                  index: i,
                  child: const Icon(Icons.drag_handle_rounded,
                      color: AppColors.textMuted),
                ),
                title: Text(games[i].title),
                subtitle: Text(
                  '${games[i].completionPercentage.toStringAsFixed(0)}% — ${games[i].medalTier.label}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 8),
    child: Text(title, style: Theme.of(context).textTheme.labelLarge!
        .copyWith(color: AppColors.accent)),
  );
}
```

---

## 16. Animações com flutter_animate

O `flutter_animate` encadeia animações por método. Padrões recomendados:

```dart
// Entrada de cards (lista)
MyWidget().animate(delay: (index * 60).ms).fadeIn().slideX(begin: 0.1)

// Escala suave (ex: header)
MyWidget().animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95))

// Brilho contínuo para diamante
Icon(Icons.diamond_rounded, color: AppColors.diamond)
  .animate(onPlay: (c) => c.repeat())
  .shimmer(duration: 1800.ms, color: AppColors.diamond.withOpacity(0.6))

// Fade + slide ao abrir modal
MyWidget().animate().fadeIn().slideY(begin: 0.05)
```

Para a barra de progresso com animação de efeito:
```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: progress),
  duration: 800.ms,
  curve: Curves.easeOutCubic,
  builder: (context, value, _) => LinearProgressIndicator(value: value),
)
```

---

## 17. Testes

### Estrutura de arquivos de teste

```
test/
├── unit/
│   ├── medal_tier_test.dart
│   ├── game_entity_test.dart
│   ├── user_preferences_datasource_test.dart
│   ├── game_repository_impl_test.dart
│   └── rawg_game_model_test.dart
└── widget/
    ├── medal_badge_test.dart
    ├── game_card_test.dart
    └── progress_header_test.dart

integration_test/
└── app_test.dart
```

---

### 5 Testes Unitários

#### `test/unit/medal_tier_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/domain/entities/medal_tier.dart';

void main() {
  group('MedalTierExtension.fromPercentage', () {
    test('retorna none para menos de 25%', () {
      expect(MedalTierExtension.fromPercentage(0),  MedalTier.none);
      expect(MedalTierExtension.fromPercentage(24), MedalTier.none);
    });

    test('retorna bronze para 25% a 49%', () {
      expect(MedalTierExtension.fromPercentage(25), MedalTier.bronze);
      expect(MedalTierExtension.fromPercentage(49), MedalTier.bronze);
    });

    test('retorna silver para 50% a 74%', () {
      expect(MedalTierExtension.fromPercentage(50), MedalTier.silver);
      expect(MedalTierExtension.fromPercentage(74), MedalTier.silver);
    });

    test('retorna gold para 75% a 99%', () {
      expect(MedalTierExtension.fromPercentage(75), MedalTier.gold);
      expect(MedalTierExtension.fromPercentage(99), MedalTier.gold);
    });

    test('retorna diamond para 100%', () {
      expect(MedalTierExtension.fromPercentage(100), MedalTier.diamond);
    });
  });
}
```

#### `test/unit/game_entity_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/domain/entities/game.dart';
import 'package:game_achievements/domain/entities/medal_tier.dart';

void main() {
  final baseGame = Game(
    id: '1',
    title: 'Hollow Knight',
    totalAchievements: 40,
    unlockedAchievements: 30,
    sortOrder: 0,
    addedAt: DateTime(2024),
  );

  group('Game.completionPercentage', () {
    test('calcula 75% corretamente', () {
      expect(baseGame.completionPercentage, 75.0);
    });

    test('retorna 0 quando não há conquistas', () {
      final g = baseGame.copyWith(totalAchievements: 0, unlockedAchievements: 0);
      expect(g.completionPercentage, 0.0);
    });
  });

  group('Game.medalTier', () {
    test('75% resulta em gold', () {
      expect(baseGame.medalTier, MedalTier.gold);
    });

    test('100% resulta em diamond', () {
      final g = baseGame.copyWith(unlockedAchievements: 40);
      expect(g.medalTier, MedalTier.diamond);
    });
  });

  test('copyWith preserva campos não modificados', () {
    final updated = baseGame.copyWith(title: 'Celeste');
    expect(updated.id, '1');
    expect(updated.title, 'Celeste');
    expect(updated.totalAchievements, 40);
  });
}
```

#### `test/unit/rawg_game_model_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/data/models/rawg_game_model.dart';

void main() {
  group('RawgGame.fromJson', () {
    test('parseia campos obrigatórios', () {
      final json = {
        'id': 123,
        'name': 'The Witcher 3',
        'background_image': 'https://example.com/img.jpg',
        'rating': 4.7,
      };
      final model = RawgGame.fromJson(json);
      expect(model.id,   123);
      expect(model.name, 'The Witcher 3');
      expect(model.backgroundImage, 'https://example.com/img.jpg');
      expect(model.rating, 4.7);
    });

    test('aceita campos opcionais nulos', () {
      final json = {'id': 1, 'name': 'Game'};
      final model = RawgGame.fromJson(json);
      expect(model.backgroundImage, isNull);
      expect(model.rating, isNull);
    });
  });
}
```

#### `test/unit/game_repository_impl_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:game_achievements/data/datasources/local/game_local_datasource.dart';
import 'package:game_achievements/data/repositories/game_repository_impl.dart';
import 'package:game_achievements/domain/entities/game.dart';

@GenerateMocks([GameLocalDatasource])
import 'game_repository_impl_test.mocks.dart';

void main() {
  late MockGameLocalDatasource mockDatasource;
  late GameRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockGameLocalDatasource();
    repository = GameRepositoryImpl(mockDatasource);
  });

  final fakeGame = Game(
    id: 'abc',
    title: 'Elden Ring',
    totalAchievements: 10,
    unlockedAchievements: 5,
    sortOrder: 0,
    addedAt: DateTime(2024),
  );

  test('getAllGames delega para datasource', () async {
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
}
```

#### `test/unit/user_preferences_datasource_test.dart`
```dart
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

  test('salva e recupera perfil corretamente', () async {
    final profile = UserProfile(
      nickname: 'Kayser',
      createdAt: DateTime(2024, 6, 16),
    );
    await datasource.saveProfile(profile);
    final recovered = await datasource.getProfile();
    expect(recovered?.nickname, 'Kayser');
  });

  test('isGridView retorna false por padrão', () async {
    expect(await datasource.isGridView(), isFalse);
  });

  test('setGridView persiste a preferência', () async {
    await datasource.setGridView(true);
    expect(await datasource.isGridView(), isTrue);
  });
}
```

Para gerar os mocks do Mockito:
```bash
dart run build_runner build
```

---

### 3 Testes de Widget

#### `test/widget/medal_badge_test.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/core/theme/app_theme.dart';
import 'package:game_achievements/domain/entities/medal_tier.dart';
import 'package:game_achievements/presentation/home/widgets/medal_badge.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('MedalBadge none não renderiza nada', (tester) async {
    await tester.pumpWidget(wrap(const MedalBadge(tier: MedalTier.none)));
    expect(find.byType(Container), findsNothing);
  });

  testWidgets('MedalBadge diamond exibe ícone de diamante', (tester) async {
    await tester.pumpWidget(wrap(const MedalBadge(tier: MedalTier.diamond)));
    await tester.pump();
    expect(find.byIcon(Icons.diamond_rounded), findsOneWidget);
  });

  testWidgets('MedalBadge gold exibe ícone military_tech', (tester) async {
    await tester.pumpWidget(wrap(const MedalBadge(tier: MedalTier.gold)));
    await tester.pump();
    expect(find.byIcon(Icons.military_tech_rounded), findsOneWidget);
  });
}
```

#### `test/widget/progress_header_test.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/core/theme/app_theme.dart';
import 'package:game_achievements/domain/entities/achievement.dart';
import 'package:game_achievements/presentation/game_detail/widgets/progress_header.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: child),
      );

  testWidgets('ProgressHeader exibe "0 / 0 conquistas" sem dados', (tester) async {
    await tester.pumpWidget(wrap(const ProgressHeader(achievements: [])));
    expect(find.textContaining('0 / 0'), findsOneWidget);
  });

  testWidgets('ProgressHeader exibe contagem correta de desbloqueados', (tester) async {
    final achievements = [
      const Achievement(id: '1', gameId: 'g1', title: 'A', isUnlocked: true),
      const Achievement(id: '2', gameId: 'g1', title: 'B', isUnlocked: false),
    ];
    await tester.pumpWidget(wrap(ProgressHeader(achievements: achievements)));
    await tester.pump(const Duration(seconds: 1)); // animação TweenAnimationBuilder
    expect(find.textContaining('1 / 2'), findsOneWidget);
  });

  testWidgets('ProgressHeader exibe label da medalha', (tester) async {
    final achievements = List.generate(
      4,
      (i) => Achievement(
          id: '$i', gameId: 'g1', title: 'A$i', isUnlocked: i < 3),
    ); // 75% = Gold
    await tester.pumpWidget(wrap(ProgressHeader(achievements: achievements)));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Ouro'), findsOneWidget);
  });
}
```

#### `test/widget/game_card_test.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_achievements/core/theme/app_theme.dart';
import 'package:game_achievements/domain/entities/game.dart';
import 'package:game_achievements/presentation/home/widgets/game_card.dart';

void main() {
  final fakeGame = Game(
    id: '1',
    title: 'Hollow Knight',
    totalAchievements: 10,
    unlockedAchievements: 5,
    sortOrder: 0,
    addedAt: DateTime(2024),
  );

  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: child),
      );

  testWidgets('GameCard exibe título do game', (tester) async {
    await tester.pumpWidget(wrap(GameCard(game: fakeGame)));
    expect(find.text('Hollow Knight'), findsOneWidget);
  });

  testWidgets('GameCard exibe progresso correto', (tester) async {
    await tester.pumpWidget(wrap(GameCard(game: fakeGame)));
    expect(find.textContaining('5 / 10'), findsOneWidget);
    expect(find.textContaining('50%'), findsOneWidget);
  });
}
```

---

### 1 Teste de Integração

#### `integration_test/app_test.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game_achievements/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Adicionar game e verificar na home', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Home screen está visível
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Abre sheet de adicionar game
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    // Sheet está visível
    expect(find.byType(BottomSheet), findsOneWidget);

    // Fecha o sheet
    await tester.tapAt(const Offset(0, 0)); // toque fora
    await tester.pumpAndSettle();

    // Navega para Perfil
    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Perfil'), findsOneWidget);

    // Volta para Home
    await tester.tap(find.byIcon(Icons.sports_esports_rounded));
    await tester.pumpAndSettle();
  });
}
```

Rodar o teste de integração:
```bash
flutter test integration_test/app_test.dart -d pixel_4
```

Rodar todos os testes unitários e de widget:
```bash
flutter test test/
```

---

## 18. Rodar no Emulador Pixel 4

```bash
# 1. Listar emuladores disponíveis
flutter emulators

# 2. Iniciar o emulador Pixel 4
flutter emulators --launch Pixel_4_API_34

# 3. Verificar se o dispositivo está disponível
flutter devices

# 4. Rodar o app
flutter run -d emulator-5554

# 5. Hot reload: pressione 'r' no terminal
# 6. Hot restart: pressione 'R' no terminal
```

Permissões necessárias no `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Dentro de <manifest> -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

---

## Checklist Final

- [ ] `pubspec.yaml` com todas as dependências
- [ ] Estrutura de pastas criada
- [ ] `AppTheme`, `AppColors`, `AppTypography` implementados
- [ ] Entidades do domínio (`Game`, `Achievement`, `UserProfile`, `MedalTier`)
- [ ] Repositórios abstratos
- [ ] `DatabaseHelper` + tabelas `games` e `achievements`
- [ ] Models com `toMap`/`fromMap`
- [ ] Datasources: local (SQLite), preferences (SharedPreferences), remote (Dio)
- [ ] Implementações de repositórios
- [ ] Providers Riverpod (games, achievements, user, gridView, search)
- [ ] GoRouter com shell + rota parametrizada `/game/:id`
- [ ] Home Screen (lista/grade + toggle)
- [ ] Game Detail Screen
- [ ] Profile Screen (trocar avatar + nickname)
- [ ] Settings Screen (reordenar games com drag)
- [ ] `MedalBadge` com shimmer para diamante
- [ ] 5 testes unitários passando
- [ ] 3 testes de widget passando
- [ ] 1 teste de integração passando
- [ ] `flutter analyze` sem erros
- [ ] App rodando no Pixel 4
