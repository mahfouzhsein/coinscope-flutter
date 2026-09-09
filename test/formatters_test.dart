import 'package:coinscope_mobile/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('market formatters', () {
    test('formats supported currency symbols', () {
      expect(formatCurrency(19850.5), r'$19,850.50');
      expect(formatCurrency(42, 'eur'), '€42.00');
      expect(formatCurrency(42, 'gbp'), '£42.00');
    });

    test('keeps precision for sub-unit assets', () {
      expect(formatCurrency(0.000042), r'$0.000042');
    });

    test('adds a sign only to positive percentages', () {
      expect(formatPercent(3.456), '+3.46%');
      expect(formatPercent(-3.456), '-3.46%');
      expect(formatPercent(0), '0.00%');
    });

    test('removes markup from CoinGecko descriptions', () {
      expect(
        stripHtml('<p>Digital <strong>money</strong>.</p>'),
        'Digital money.',
      );
    });
  });
}
