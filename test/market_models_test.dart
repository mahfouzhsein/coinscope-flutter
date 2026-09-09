import 'package:coinscope_mobile/features/market/domain/market_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CryptoCoin tolerates nullable market fields', () {
    final coin = CryptoCoin.fromJson({
      'id': 'bitcoin',
      'symbol': 'btc',
      'name': 'Bitcoin',
      'image': 'https://example.com/bitcoin.png',
      'market_cap_rank': 1,
      'current_price': 50000,
      'price_change_percentage_24h': null,
      'market_cap': 1000000000,
    });

    expect(coin.id, 'bitcoin');
    expect(coin.rank, 1);
    expect(coin.currentPrice, 50000);
    expect(coin.priceChange24h, 0);
  });

  test('CoinDetail reads prices by currency', () {
    final coin = CoinDetail.fromJson({
      'id': 'ethereum',
      'symbol': 'eth',
      'name': 'Ethereum',
      'market_data': {
        'current_price': {'usd': 3200, 'eur': 2950.5},
      },
    });

    expect(coin.price('usd'), 3200);
    expect(coin.price('eur'), 2950.5);
    expect(coin.price('gbp'), 0);
  });

  test('PricePoint converts CoinGecko timestamps', () {
    final point = PricePoint.fromJson([1704067200000, 42000.25]);

    expect(point.time.toUtc(), DateTime.utc(2024));
    expect(point.price, 42000.25);
  });
}
