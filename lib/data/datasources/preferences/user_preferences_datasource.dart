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

  Future<bool> isGridView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGridView) ?? false;
  }

  Future<void> setGridView(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGridView, value);
  }
}
