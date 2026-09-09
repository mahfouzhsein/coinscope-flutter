import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/async_widgets.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../core/widgets/typography.dart';
import '../../preferences/application/preferences_provider.dart';
import '../../watchlist/presentation/watch_button.dart';
import '../application/market_providers.dart';
import '../domain/market_models.dart';
import 'widgets/coin_avatar.dart';
import 'widgets/coin_change.dart';
import 'widgets/price_chart_card.dart';

class CoinDetailScreen extends ConsumerStatefulWidget {
  const CoinDetailScreen({required this.coinId, super.key});

  final String coinId;

  @override
  ConsumerState<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends ConsumerState<CoinDetailScreen> {
  int _days = 7;

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesProvider);
    return AppBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const AppLogo(showName: false),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1),
          ),
        ),
        body: ResponsivePage(
          child: preferences.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: LoadingCard(lines: 8),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(20),
              child: ErrorCard(
                message: error.toString(),
                onRetry: () => ref.invalidate(preferencesProvider),
              ),
            ),
            data: (value) => _buildDetail(value.currency),
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String currency) {
    final detail = ref.watch(coinDetailProvider(widget.coinId));
    return detail.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: LoadingCard(lines: 10),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: ErrorCard(
          title: 'Asset details unavailable',
          message: error.toString(),
          onRetry: () => ref.invalidate(coinDetailProvider(widget.coinId)),
        ),
      ),
      data: (coin) => _DetailContent(
        coin: coin,
        currency: currency,
        days: _days,
        onDaysChanged: (value) => setState(() => _days = value),
        onRefresh: () async {
          ref.invalidate(coinDetailProvider(widget.coinId));
          ref.invalidate(
            priceHistoryProvider(
              PriceHistoryRequest(
                id: widget.coinId,
                currency: currency,
                days: _days,
              ),
            ),
          );
          await ref.read(coinDetailProvider(widget.coinId).future);
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.coin,
    required this.currency,
    required this.days,
    required this.onDaysChanged,
    required this.onRefresh,
  });

  final CoinDetail coin;
  final String currency;
  final int days;
  final ValueChanged<int> onDaysChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final cleanDescription = stripHtml(coin.description);
    final description = cleanDescription
        .split(RegExp(r'(?<=[.!?])\s+'))
        .take(4)
        .join(' ');

    return RefreshIndicator(
      color: AppColors.cyan,
      backgroundColor: AppColors.surfaceSolid,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        children: [
          _CoinHero(coin: coin, currency: currency),
          const SizedBox(height: 16),
          PriceChartCard(
            coinId: coin.id,
            currency: currency,
            days: days,
            onDaysChanged: onDaysChanged,
          ),
          const SizedBox(height: 16),
          _MarketStatistics(coin: coin, currency: currency),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('About'),
                  const SizedBox(height: 6),
                  Text(
                    coin.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.muted,
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CoinHero extends StatelessWidget {
  const _CoinHero({required this.coin, required this.currency});

  final CoinDetail coin;
  final String currency;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CoinAvatar(url: coin.imageUrl, name: coin.name, size: 58),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          coin.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          coin.symbol.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Market rank #${coin.rank ?? '—'}',
                    style: const TextStyle(
                      color: AppColors.subtle,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            WatchButton(coinId: coin.id),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              formatCurrency(coin.price(currency), currency),
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            CoinChange(value: coin.priceChange24h, fontSize: 17),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '24h change ${formatPercent(coin.priceChange24h)}',
          style: const TextStyle(color: AppColors.subtle, fontSize: 12),
        ),
      ],
    ),
  );
}

class _MarketStatistics extends StatelessWidget {
  const _MarketStatistics({required this.coin, required this.currency});

  final CoinDetail coin;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        'Market cap',
        formatCompactCurrency(coin.marketCaps[currency], currency),
      ),
      ('24h volume', formatCompactCurrency(coin.volumes[currency], currency)),
      ('24h high', formatCurrency(coin.highs24h[currency], currency)),
      ('24h low', formatCurrency(coin.lows24h[currency], currency)),
      ('Circulating supply', formatCompactNumber(coin.circulatingSupply)),
      ('All-time high', formatCurrency(coin.allTimeHighs[currency], currency)),
    ];

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Snapshot'),
          const SizedBox(height: 6),
          Text(
            'Market statistics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...stats.map(
            (stat) => Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      stat.$1,
                      style: const TextStyle(color: AppColors.subtle),
                    ),
                  ),
                  Text(
                    stat.$2,
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
