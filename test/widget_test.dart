import 'package:coinscope_mobile/core/theme/app_colors.dart';
import 'package:coinscope_mobile/core/widgets/web_download_banner.dart';
import 'package:coinscope_mobile/features/market/presentation/widgets/coin_change.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CoinChange presents gains and losses clearly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [CoinChange(value: 2.5), CoinChange(value: -1.25)],
          ),
        ),
      ),
    );

    expect(find.text('+2.50%'), findsOneWidget);
    expect(find.text('-1.25%'), findsOneWidget);

    final gain = tester.widget<Text>(find.text('+2.50%'));
    final loss = tester.widget<Text>(find.text('-1.25%'));
    expect(gain.style?.color, AppColors.positive);
    expect(loss.style?.color, AppColors.negative);
  });

  testWidgets('web download banner presents both native builds', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WebDownloadBanner())),
    );

    expect(find.text('Get the native app'), findsOneWidget);
    expect(find.text('Android APK'), findsOneWidget);
    expect(find.text('Windows ZIP'), findsOneWidget);
  });
}
