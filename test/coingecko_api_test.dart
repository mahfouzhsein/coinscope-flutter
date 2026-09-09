import 'package:coinscope_mobile/features/market/data/coingecko_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'market request uses the public CoinGecko endpoint without an API key',
    () async {
      final client = MockClient((request) async {
        expect(request.url.scheme, 'https');
        expect(request.url.host, 'api.coingecko.com');
        expect(request.url.path, '/api/v3/coins/markets');
        expect(request.url.queryParameters['vs_currency'], 'eur');
        expect(request.headers.keys, isNot(contains('x-cg-demo-api-key')));
        expect(request.headers.keys, isNot(contains('x-cg-pro-api-key')));
        return http.Response('[]', 200);
      });
      final api = CoinGeckoApi(client: client);

      final coins = await api.fetchMarkets(currency: 'eur');

      expect(coins, isEmpty);
      api.dispose();
    },
  );

  test('rate-limit responses become a readable domain error', () async {
    final api = CoinGeckoApi(
      client: MockClient((_) async => http.Response('{}', 429)),
    );

    await expectLater(
      api.fetchTrending(),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 429)
            .having(
              (error) => error.message,
              'message',
              contains('rate limit'),
            ),
      ),
    );
    api.dispose();
  });
}
