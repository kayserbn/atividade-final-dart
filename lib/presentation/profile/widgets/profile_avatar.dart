import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_profile.dart';
import '../../providers/user_provider.dart';

class ProfileAvatar extends ConsumerWidget {
  final UserProfile? profile;
  const ProfileAvatar({super.key, this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _pickAvatar(context, ref),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2.5),
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage: profile?.avatarPath != null
                  ? FileImage(File(profile!.avatarPath!))
                  : null,
              child: profile?.avatarPath == null
                  ? const Icon(Icons.person_rounded,
                      size: 52, color: AppColors.textMuted)
                  : null,
            ),
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

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final current = profile ??
        UserProfile(nickname: 'Jogador', createdAt: DateTime.now());
    await ref
        .read(userProfileProvider.notifier)
        .save(current.copyWith(avatarPath: picked.path));
  }
}
