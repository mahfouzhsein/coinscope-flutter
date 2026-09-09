import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../preferences/application/preferences_provider.dart';
import '../../watchlist/application/watchlist_provider.dart';
import '../data/coingecko_api.dart';
import '../domain/market_models.dart';

final coinGeckoApiProvider = Provider<CoinGeckoApi>((ref) {
  final api = CoinGeckoApi();
  ref.onDispose(api.dispose);
  return api;
});

final globalMarketProvider = FutureProvider<GlobalMarket>((ref) {
  return ref.watch(coinGeckoApiProvider).fetchGlobalMarket();
});

final trendingCoinsProvider = FutureProvider<List<TrendingCoin>>((ref) {
  return ref.watch(coinGeckoApiProvider).fetchTrending();
});

final marketLeadersProvider = FutureProvider<List<CryptoCoin>>((ref) {
  return ref.watch(coinGeckoApiProvider).fetchMarkets(perPage: 6);
});

class MarketsQuery {
  const MarketsQuery({
    required this.currency,
    required this.page,
    required this.perPage,
  });

  final String currency;
  final int page;
  final int perPage;

  @override
  bool operator ==(Object other) {
    return other is MarketsQuery &&
        other.currency == currency &&
        other.page == page &&
        other.perPage == perPage;
  }

  @override
  int get hashCode => Object.hash(currency, page, perPage);
}

final marketsProvider = FutureProvider.autoDispose
    .family<List<CryptoCoin>, MarketsQuery>((ref, query) {
      return ref
          .watch(coinGeckoApiProvider)
          .fetchMarkets(
            currency: query.currency,
            page: query.page,
            perPage: query.perPage,
          );
    });

final coinDetailProvider = FutureProvider.autoDispose
    .family<CoinDetail, String>((ref, id) {
      return ref.watch(coinGeckoApiProvider).fetchCoin(id);
    });

class PriceHistoryRequest {
  const PriceHistoryRequest({
    required this.id,
    required this.currency,
    required this.days,
  });

  final String id;
  final String currency;
  final int days;

  @override
  bool operator ==(Object other) {
    return other is PriceHistoryRequest &&
        other.id == id &&
        other.currency == currency &&
        other.days == days;
  }

  @override
  int get hashCode => Object.hash(id, currency, days);
}

final priceHistoryProvider = FutureProvider.autoDispose
    .family<List<PricePoint>, PriceHistoryRequest>((ref, request) {
      return ref
          .watch(coinGeckoApiProvider)
          .fetchPriceHistory(
            id: request.id,
            currency: request.currency,
            days: request.days,
          );
    });

final watchlistCoinsProvider = FutureProvider.autoDispose<List<CryptoCoin>>((
  ref,
) async {
  final ids = await ref.watch(watchlistProvider.future);
  if (ids.isEmpty) return const [];
  final preferences = await ref.watch(preferencesProvider.future);
  return ref
      .watch(coinGeckoApiProvider)
      .fetchMarkets(
        currency: preferences.currency,
        perPage: 100,
        ids: ids.toList(growable: false),
      );
});
