import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String username;

  /// Caminho absoluto local da foto de perfil (pode ser null)
  @HiveField(1)
  String? profileImagePath;

  UserModel({
    required this.username,
    this.profileImagePath,
  });
}
