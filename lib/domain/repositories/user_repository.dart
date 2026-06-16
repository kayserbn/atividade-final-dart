import '../entities/user_profile.dart';

abstract interface class UserRepository {
  Future<UserProfile?> getProfile();
  Future<void> saveProfile(UserProfile profile);
}
