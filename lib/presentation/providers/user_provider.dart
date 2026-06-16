import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/preferences/user_preferences_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

final userPreferencesDatasourceProvider = Provider<UserPreferencesDatasource>(
  (_) => UserPreferencesDatasource(),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(ref.watch(userPreferencesDatasourceProvider)),
);

class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() =>
      ref.watch(userRepositoryProvider).getProfile();

  Future<void> save(UserProfile profile) async {
    await ref.read(userRepositoryProvider).saveProfile(profile);
    ref.invalidateSelf();
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile?>(
  UserProfileNotifier.new,
);

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
