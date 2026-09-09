import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/market_models.dart';

class CoinGeckoApi {
  CoinGeckoApi({http.Client? client}) : _client = client ?? http.Client();

  static const _host = 'api.coingecko.com';
  static const _timeout = Duration(seconds: 12);
  final http.Client _client;

  Future<GlobalMarket> fetchGlobalMarket() async {
    final json = await _get('/global');
    return GlobalMarket.fromJson(json as Map<String, dynamic>);
  }

  Future<List<TrendingCoin>> fetchTrending() async {
    final json = await _get('/search/trending') as Map<String, dynamic>;
    final rows = json['coins'] as List? ?? const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(TrendingCoin.fromJson)
        .toList(growable: false);
  }

  Future<List<CryptoCoin>> fetchMarkets({
    String currency = 'usd',
    int page = 1,
    int perPage = 20,
    List<String> ids = const [],
  }) async {
    final json = await _get(
      '/coins/markets',
      query: {
        'vs_currency': currency,
        'order': 'market_cap_desc',
        'per_page': '$perPage',
        'page': '$page',
        'sparkline': 'false',
        'price_change_percentage': '1h,24h,7d',
        if (ids.isNotEmpty) 'ids': ids.join(','),
      },
    );
    return (json as List)
        .whereType<Map<String, dynamic>>()
        .map(CryptoCoin.fromJson)
        .toList(growable: false);
  }

  Future<CoinDetail> fetchCoin(String id) async {
    final json = await _get(
      '/coins/$id',
      query: const {
        'localization': 'false',
        'tickers': 'false',
        'market_data': 'true',
        'community_data': 'false',
        'developer_data': 'false',
        'sparkline': 'false',
      },
    );
    return CoinDetail.fromJson(json as Map<String, dynamic>);
  }

  Future<List<PricePoint>> fetchPriceHistory({
    required String id,
    required String currency,
    required int days,
  }) async {
    final json = await _get(
      '/coins/$id/market_chart',
      query: {'vs_currency': currency, 'days': '$days'},
    ) as Map<String, dynamic>;
    final rows = json['prices'] as List? ?? const [];
    return rows
        .whereType<List<dynamic>>()
        .where((row) => row.isNotEmpty)
        .map(PricePoint.fromJson)
        .toList(growable: false);
  }

  Future<dynamic> _get(
    String path, {
    Map<String, String> query = const {},
  }) async {
    final uri = Uri.https(_host, '/api/v3$path', query);
    try {
      final response = await _client
          .get(uri, headers: const {'accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode == 429) {
        throw const ApiException(
          'CoinGecko rate limit reached. Please retry shortly.',
          statusCode: 429,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'Market data is temporarily unavailable.',
          statusCode: response.statusCode,
        );
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException {
      throw const ApiException('The market request timed out. Please retry.');
    } on SocketException {
      throw const ApiException('No internet connection. Please try again.');
    } on FormatException {
      throw const ApiException('CoinGecko returned an invalid response.');
    }
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
