import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_widgets.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../core/widgets/typography.dart';
import '../../market/application/market_providers.dart';
import '../../market/domain/market_models.dart';
import '../../market/presentation/navigation.dart';
import '../../market/presentation/widgets/coin_avatar.dart';
import '../../market/presentation/widgets/coin_change.dart';
import '../../preferences/application/preferences_provider.dart';
import '../application/watchlist_provider.dart';
import 'watch_button.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);
    return RefreshIndicator(
      color: AppColors.cyan,
      backgroundColor: AppColors.surfaceSolid,
      onRefresh: () async {
        ref.invalidate(watchlistCoinsProvider);
        if ((watchlist.value?.isNotEmpty ?? false)) {
          await ref.read(watchlistCoinsProvider.future);
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        children: [
          const ScreenHeading(
            eyebrow: 'Your market',
            title: 'Watchlist',
            subtitle:
                'A persistent shortlist of the assets you care about most.',
          ),
          const SizedBox(height: 22),
          watchlist.when(
            loading: () => const LoadingCard(lines: 6),
            error: (error, _) => ErrorCard(
              message: error.toString(),
              onRetry: () => ref.invalidate(watchlistProvider),
            ),
            data: (ids) => ids.isEmpty
                ? const _EmptyWatchlist()
                : const _WatchlistResults(),
          ),
        ],
      ),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist();

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.star_border_rounded,
              color: AppColors.watch,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your watchlist is empty',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add assets from Markets to keep your highest-conviction coins in one persistent view.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
        ],
      ),
    ),
  );
}

class _WatchlistResults extends ConsumerWidget {
  const _WatchlistResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(watchlistCoinsProvider);
    final currency = ref.watch(preferencesProvider).value?.currency ?? 'usd';
    return coins.when(
      loading: () => const LoadingCard(lines: 6),
      error: (error, _) => ErrorCard(
        message: error.toString(),
        onRetry: () => ref.invalidate(watchlistCoinsProvider),
      ),
      data: (items) => Column(
        children: items
            .map(
              (coin) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WatchlistCard(coin: coin, currency: currency),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _WatchlistCard extends StatelessWidget {
  const _WatchlistCard({required this.coin, required this.currency});

  final CryptoCoin coin;
  final String currency;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    onTap: () => openCoinDetails(context, coin.id),
    child: Column(
      children: [
        Row(
          children: [
            CoinAvatar(url: coin.imageUrl, name: coin.name, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    coin.symbol.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.subtle,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            WatchButton(coinId: coin.id),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatCurrency(coin.currentPrice, currency),
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            CoinChange(value: coin.priceChange24h),
          ],
        ),
      ],
    ),
  );
}
