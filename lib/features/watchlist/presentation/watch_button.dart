import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../application/watchlist_provider.dart';

class WatchButton extends ConsumerWidget {
  const WatchButton({required this.coinId, super.key});

  final String coinId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);
    final isWatched = watchlist.value?.contains(coinId) ?? false;

    return Semantics(
      button: true,
      label: isWatched ? 'Remove from watchlist' : 'Add to watchlist',
      child: IconButton(
        onPressed: watchlist.hasValue
            ? () => ref.read(watchlistProvider.notifier).toggle(coinId)
            : null,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surfaceSolid,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        color: isWatched ? AppColors.watch : AppColors.subtle,
        disabledColor: AppColors.subtle,
        icon: Icon(isWatched ? Icons.star_rounded : Icons.star_border_rounded),
      ),
    );
  }
}
