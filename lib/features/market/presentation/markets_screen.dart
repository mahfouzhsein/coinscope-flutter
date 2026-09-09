import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_widgets.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../core/widgets/typography.dart';
import '../../preferences/application/preferences_provider.dart';
import '../../watchlist/presentation/watch_button.dart';
import '../application/market_providers.dart';
import '../domain/market_models.dart';
import 'navigation.dart';
import 'widgets/coin_avatar.dart';
import 'widgets/coin_change.dart';

enum _SortKey { rank, price, change, marketCap }

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen> {
  final _searchController = TextEditingController();
  int _page = 1;
  _SortKey _sortKey = _SortKey.rank;
  bool _ascending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesProvider);
    return preferences.when(
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
      data: _buildMarkets,
    );
  }

  Widget _buildMarkets(PreferencesState preferences) {
    final query = MarketsQuery(
      currency: preferences.currency,
      page: _page,
      perPage: preferences.rowsPerPage,
    );
    final markets = ref.watch(marketsProvider(query));

    return RefreshIndicator(
      color: AppColors.cyan,
      backgroundColor: AppColors.surfaceSolid,
      onRefresh: () async {
        ref.invalidate(marketsProvider(query));
        await ref.read(marketsProvider(query).future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        children: [
          const ScreenHeading(
            eyebrow: 'Live market data',
            title: 'Markets',
            subtitle: 'Search, sort and inspect the assets driving the market.',
          ),
          const SizedBox(height: 22),
          _MarketControls(
            controller: _searchController,
            preferences: preferences,
            sortKey: _sortKey,
            ascending: _ascending,
            onSearch: (_) => setState(() {}),
            onCurrency: (value) {
              setState(() => _page = 1);
              ref.read(preferencesProvider.notifier).setCurrency(value);
            },
            onRows: (value) {
              setState(() => _page = 1);
              ref.read(preferencesProvider.notifier).setRowsPerPage(value);
            },
            onSort: (value) => setState(() {
              if (_sortKey == value) {
                _ascending = !_ascending;
              } else {
                _sortKey = value;
                _ascending = value == _SortKey.rank;
              }
            }),
          ),
          const SizedBox(height: 14),
          markets.when(
            loading: () => const LoadingCard(lines: 10),
            error: (error, _) => ErrorCard(
              message: error.toString(),
              onRetry: () => ref.invalidate(marketsProvider(query)),
            ),
            data: (coins) => _MarketResults(
              coins: _sortedAndFiltered(coins),
              currency: preferences.currency,
              page: _page,
              onPrevious: _page == 1 ? null : () => setState(() => _page--),
              onNext: coins.length < preferences.rowsPerPage
                  ? null
                  : () => setState(() => _page++),
            ),
          ),
        ],
      ),
    );
  }

  List<CryptoCoin> _sortedAndFiltered(List<CryptoCoin> source) {
    final needle = _searchController.text.trim().toLowerCase();
    final coins = source.where((coin) {
      return needle.isEmpty ||
          '${coin.name} ${coin.symbol}'.toLowerCase().contains(needle);
    }).toList();
    coins.sort((left, right) {
      final comparison = switch (_sortKey) {
        _SortKey.rank => (left.rank ?? 999999).compareTo(right.rank ?? 999999),
        _SortKey.price => left.currentPrice.compareTo(right.currentPrice),
        _SortKey.change => left.priceChange24h.compareTo(right.priceChange24h),
        _SortKey.marketCap => left.marketCap.compareTo(right.marketCap),
      };
      return _ascending ? comparison : -comparison;
    });
    return coins;
  }
}

class _MarketControls extends StatelessWidget {
  const _MarketControls({
    required this.controller,
    required this.preferences,
    required this.sortKey,
    required this.ascending,
    required this.onSearch,
    required this.onCurrency,
    required this.onRows,
    required this.onSort,
  });

  final TextEditingController controller;
  final PreferencesState preferences;
  final _SortKey sortKey;
  final bool ascending;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onCurrency;
  final ValueChanged<int> onRows;
  final ValueChanged<_SortKey> onSort;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      children: [
        TextField(
          controller: controller,
          onChanged: onSearch,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search this page…',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                key: ValueKey(preferences.currency),
                initialValue: preferences.currency,
                isDense: true,
                decoration: const InputDecoration(labelText: 'Currency'),
                items: const [
                  DropdownMenuItem(value: 'usd', child: Text('USD')),
                  DropdownMenuItem(value: 'eur', child: Text('EUR')),
                  DropdownMenuItem(value: 'gbp', child: Text('GBP')),
                ],
                onChanged: (value) {
                  if (value != null) onCurrency(value);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<int>(
                key: ValueKey(preferences.rowsPerPage),
                initialValue: preferences.rowsPerPage,
                isDense: true,
                decoration: const InputDecoration(labelText: 'Rows'),
                items: const [
                  DropdownMenuItem(value: 10, child: Text('10')),
                  DropdownMenuItem(value: 20, child: Text('20')),
                  DropdownMenuItem(value: 50, child: Text('50')),
                ],
                onChanged: (value) {
                  if (value != null) onRows(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PopupMenuButton<_SortKey>(
          onSelected: onSort,
          color: AppColors.surfaceSolid,
          itemBuilder: (_) => _SortKey.values
              .map(
                (value) =>
                    PopupMenuItem(value: value, child: Text(_sortLabel(value))),
              )
              .toList(growable: false),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.backgroundDeep,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sort_rounded,
                  color: AppColors.subtle,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text('Sort: ${_sortLabel(sortKey)}')),
                Icon(
                  ascending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: AppColors.cyanSoft,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  String _sortLabel(_SortKey key) => switch (key) {
    _SortKey.rank => 'Market rank',
    _SortKey.price => 'Price',
    _SortKey.change => '24h change',
    _SortKey.marketCap => 'Market cap',
  };
}

class _MarketResults extends StatelessWidget {
  const _MarketResults({
    required this.coins,
    required this.currency,
    required this.page,
    required this.onPrevious,
    required this.onNext,
  });

  final List<CryptoCoin> coins;
  final String currency;
  final int page;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      children: [
        if (coins.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 34),
            child: Text(
              'No assets match your search.',
              style: TextStyle(color: AppColors.subtle),
            ),
          )
        else
          ...coins.map((coin) => _MarketRow(coin: coin, currency: currency)),
        const Divider(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onPrevious,
                child: const Text('← Previous'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'Page $page',
                style: const TextStyle(color: AppColors.subtle, fontSize: 12),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: onNext,
                child: const Text('Next →'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _MarketRow extends StatelessWidget {
  const _MarketRow({required this.coin, required this.currency});

  final CryptoCoin coin;
  final String currency;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => openCoinDetails(context, coin.id),
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CoinAvatar(url: coin.imageUrl, name: coin.name, size: 42),
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
                const SizedBox(height: 2),
                Text(
                  '#${coin.rank ?? '—'} · ${coin.symbol.toUpperCase()}',
                  style: const TextStyle(color: AppColors.subtle, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(coin.currentPrice, currency),
                style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
              ),
              const SizedBox(height: 3),
              CoinChange(value: coin.priceChange24h, fontSize: 12),
            ],
          ),
          const SizedBox(width: 5),
          WatchButton(coinId: coin.id),
        ],
      ),
    ),
  );
}
