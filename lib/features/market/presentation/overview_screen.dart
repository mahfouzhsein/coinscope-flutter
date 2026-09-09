import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_widgets.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../core/widgets/typography.dart';
import '../application/market_providers.dart';
import '../domain/market_models.dart';
import 'navigation.dart';
import 'widgets/coin_avatar.dart';
import 'widgets/coin_change.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(globalMarketProvider);
    ref.invalidate(trendingCoinsProvider);
    ref.invalidate(marketLeadersProvider);
    await Future.wait([
      ref.read(globalMarketProvider.future),
      ref.read(trendingCoinsProvider.future),
      ref.read(marketLeadersProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.cyan,
      backgroundColor: AppColors.surfaceSolid,
      onRefresh: () => _refresh(ref),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        children: [
          const Eyebrow('Crypto market intelligence'),
          const SizedBox(height: 12),
          const Text(
            'See the market clearly.',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 36,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'A fast, resilient Flutter dashboard for tracking global crypto metrics, market leaders and assets worth watching.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 16,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 26),
          const _MarketStats(),
          const SizedBox(height: 20),
          const _TrendingSection(),
          const SizedBox(height: 20),
          const _LeadersSection(),
        ],
      ),
    );
  }
}

class _MarketStats extends ConsumerWidget {
  const _MarketStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final market = ref.watch(globalMarketProvider);
    return market.when(
      loading: () => const LoadingCard(lines: 4),
      error: (error, _) => ErrorCard(
        title: 'Global market metrics unavailable',
        message: error.toString(),
        onRetry: () => ref.invalidate(globalMarketProvider),
      ),
      data: (data) {
        final stats = [
          ('Market cap', formatCompactCurrency(data.marketCapUsd)),
          ('24h volume', formatCompactCurrency(data.volumeUsd)),
          ('BTC dominance', '${data.btcDominance.toStringAsFixed(1)}%'),
          ('Active coins', formatInteger(data.activeCoins)),
        ];
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: stats
                  .map(
                    (stat) => SizedBox(
                      width: width,
                      child: SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stat.$1,
                              style: const TextStyle(color: AppColors.subtle),
                            ),
                            const SizedBox(height: 9),
                            Text(
                              stat.$2,
                              maxLines: 1,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        );
      },
    );
  }
}

class _TrendingSection extends ConsumerWidget {
  const _TrendingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingCoinsProvider);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            eyebrow: 'Momentum',
            title: 'Trending now',
            trailing: 'CoinGecko',
          ),
          const SizedBox(height: 12),
          trending.when(
            loading: () => const SkeletonList(lines: 6),
            error: (error, _) => ErrorCard(
              title: 'Trending assets unavailable',
              message: error.toString(),
              onRetry: () => ref.invalidate(trendingCoinsProvider),
            ),
            data: (coins) => Column(
              children: coins
                  .take(6)
                  .map((coin) {
                    return InkWell(
                      onTap: () => openCoinDetails(context, coin.id),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            CoinAvatar(
                              url: coin.imageUrl,
                              name: coin.name,
                              size: 34,
                            ),
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
                                      fontWeight: FontWeight.w600,
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
                            Text(
                              '#${coin.rank ?? '—'}',
                              style: const TextStyle(
                                color: AppColors.subtle,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadersSection extends ConsumerWidget {
  const _LeadersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaders = ref.watch(marketLeadersProvider);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(eyebrow: 'Leaders', title: 'Largest assets'),
          const SizedBox(height: 12),
          leaders.when(
            loading: () => const SkeletonList(lines: 6),
            error: (error, _) => ErrorCard(
              title: 'Market leaders unavailable',
              message: error.toString(),
              onRetry: () => ref.invalidate(marketLeadersProvider),
            ),
            data: (coins) => Column(
              children: coins
                  .map((coin) => _LeaderRow(coin: coin))
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.coin});

  final CryptoCoin coin;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => openCoinDetails(context, coin.id),
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${coin.rank ?? '—'}',
              style: const TextStyle(color: AppColors.subtle, fontSize: 12),
            ),
          ),
          CoinAvatar(url: coin.imageUrl, name: coin.name, size: 34),
          const SizedBox(width: 11),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  coin.symbol.toUpperCase(),
                  style: const TextStyle(color: AppColors.subtle, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(coin.currentPrice),
                style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
              ),
              CoinChange(value: coin.priceChange24h, fontSize: 12),
            ],
          ),
        ],
      ),
    ),
  );
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(eyebrow),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
      if (trailing != null)
        Text(
          trailing!,
          style: const TextStyle(color: AppColors.subtle, fontSize: 11),
        ),
    ],
  );
}
