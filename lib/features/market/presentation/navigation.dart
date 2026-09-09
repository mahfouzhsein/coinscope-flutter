import 'package:flutter/material.dart';

import 'coin_detail_screen.dart';

void openCoinDetails(BuildContext context, String coinId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => CoinDetailScreen(coinId: coinId)),
  );
}
