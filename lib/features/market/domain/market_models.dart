double _toDouble(Object? value) => value is num ? value.toDouble() : 0;

int? _toInt(Object? value) => value is num ? value.toInt() : null;

Map<String, double> _moneyMap(Object? value) {
  if (value is! Map) return const {};
  return value.map((key, item) => MapEntry(key.toString(), _toDouble(item)));
}

class CryptoCoin {
  const CryptoCoin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.rank,
    required this.currentPrice,
    required this.priceChange24h,
    required this.marketCap,
  });

  factory CryptoCoin.fromJson(Map<String, dynamic> json) => CryptoCoin(
    id: json['id']?.toString() ?? '',
    symbol: json['symbol']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    imageUrl: json['image']?.toString() ?? '',
    rank: _toInt(json['market_cap_rank']),
    currentPrice: _toDouble(json['current_price']),
    priceChange24h: _toDouble(json['price_change_percentage_24h']),
    marketCap: _toDouble(json['market_cap']),
  );

  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  final int? rank;
  final double currentPrice;
  final double priceChange24h;
  final double marketCap;
}

class TrendingCoin {
  const TrendingCoin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.rank,
  });

  factory TrendingCoin.fromJson(Map<String, dynamic> json) {
    final item = json['item'] is Map<String, dynamic>
        ? json['item'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return TrendingCoin(
      id: item['id']?.toString() ?? '',
      symbol: item['symbol']?.toString() ?? '',
      name: item['name']?.toString() ?? '',
      imageUrl: item['small']?.toString() ?? '',
      rank: _toInt(item['market_cap_rank']),
    );
  }

  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  final int? rank;
}

class GlobalMarket {
  const GlobalMarket({
    required this.marketCapUsd,
    required this.volumeUsd,
    required this.btcDominance,
    required this.activeCoins,
  });

  factory GlobalMarket.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return GlobalMarket(
      marketCapUsd: _toDouble((data['total_market_cap'] as Map?)?['usd']),
      volumeUsd: _toDouble((data['total_volume'] as Map?)?['usd']),
      btcDominance: _toDouble((data['market_cap_percentage'] as Map?)?['btc']),
      activeCoins: _toInt(data['active_cryptocurrencies']) ?? 0,
    );
  }

  final double marketCapUsd;
  final double volumeUsd;
  final double btcDominance;
  final int activeCoins;
}

class CoinDetail {
  const CoinDetail({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.rank,
    required this.description,
    required this.currentPrices,
    required this.marketCaps,
    required this.volumes,
    required this.highs24h,
    required this.lows24h,
    required this.allTimeHighs,
    required this.priceChange24h,
    required this.circulatingSupply,
  });

  factory CoinDetail.fromJson(Map<String, dynamic> json) {
    final market = json['market_data'] is Map<String, dynamic>
        ? json['market_data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final images = json['image'] as Map?;
    final descriptions = json['description'] as Map?;

    return CoinDetail(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: images?['large']?.toString() ?? '',
      rank: _toInt(json['market_cap_rank']),
      description: descriptions?['en']?.toString() ?? '',
      currentPrices: _moneyMap(market['current_price']),
      marketCaps: _moneyMap(market['market_cap']),
      volumes: _moneyMap(market['total_volume']),
      highs24h: _moneyMap(market['high_24h']),
      lows24h: _moneyMap(market['low_24h']),
      allTimeHighs: _moneyMap(market['ath']),
      priceChange24h: _toDouble(market['price_change_percentage_24h']),
      circulatingSupply: _toDouble(market['circulating_supply']),
    );
  }

  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  final int? rank;
  final String description;
  final Map<String, double> currentPrices;
  final Map<String, double> marketCaps;
  final Map<String, double> volumes;
  final Map<String, double> highs24h;
  final Map<String, double> lows24h;
  final Map<String, double> allTimeHighs;
  final double priceChange24h;
  final double circulatingSupply;

  double price(String currency) => currentPrices[currency] ?? 0;
}

class PricePoint {
  const PricePoint({required this.time, required this.price});

  factory PricePoint.fromJson(List<dynamic> json) => PricePoint(
    time: DateTime.fromMillisecondsSinceEpoch((json.first as num).toInt()),
    price: _toDouble(json.length > 1 ? json[1] : null),
  );

  final DateTime time;
  final double price;
}
