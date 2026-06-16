import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/preferences/user_preferences_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserPreferencesDatasource _prefs;
  UserRepositoryImpl(this._prefs);

  @override
  Future<UserProfile?> getProfile() => _prefs.getProfile();

  @override
  Future<void> saveProfile(UserProfile profile) => _prefs.saveProfile(profile);
}
