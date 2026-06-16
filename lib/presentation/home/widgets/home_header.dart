import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname =
        ref.watch(userProfileProvider).valueOrNull?.nickname ?? 'Jogador';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Olá, $nickname',
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(color: AppColors.textPrimary),
        ),
        Text(
          'Suas conquistas',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
