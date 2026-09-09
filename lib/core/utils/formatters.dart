import 'package:intl/intl.dart';

String currencySymbol(String code) => switch (code.toLowerCase()) {
  'eur' => '€',
  'gbp' => '£',
  _ => r'$',
};

String formatCurrency(num? value, [String code = 'usd']) {
  final amount = (value ?? 0).toDouble();
  return NumberFormat.currency(
    locale: 'en_US',
    symbol: currencySymbol(code),
    decimalDigits: amount.abs() < 1 ? 6 : 2,
  ).format(amount);
}

String formatCompactCurrency(num? value, [String code = 'usd']) {
  return NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: currencySymbol(code),
    decimalDigits: 2,
  ).format(value ?? 0);
}

String formatCompactNumber(num? value) =>
    NumberFormat.compact(locale: 'en_US').format(value ?? 0);

String formatInteger(num? value) =>
    NumberFormat.decimalPattern('en_US').format(value ?? 0);

String formatPercent(num? value) {
  final number = (value ?? 0).toDouble();
  return '${number > 0 ? '+' : ''}${number.toStringAsFixed(2)}%';
}

String stripHtml(String value) => value
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
