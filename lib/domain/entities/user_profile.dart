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
