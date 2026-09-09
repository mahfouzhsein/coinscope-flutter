import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesState {
  const PreferencesState({this.currency = 'usd', this.rowsPerPage = 20});

  final String currency;
  final int rowsPerPage;

  PreferencesState copyWith({String? currency, int? rowsPerPage}) {
    return PreferencesState(
      currency: currency ?? this.currency,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
    );
  }
}

class PreferencesNotifier extends AsyncNotifier<PreferencesState> {
  static const _currencyKey = 'coinscope:currency';
  static const _rowsKey = 'coinscope:rows';
  final _preferences = SharedPreferencesAsync();

  @override
  Future<PreferencesState> build() async {
    final currency = await _preferences.getString(_currencyKey) ?? 'usd';
    final rows = await _preferences.getInt(_rowsKey) ?? 20;
    return PreferencesState(
      currency: const {'usd', 'eur', 'gbp'}.contains(currency)
          ? currency
          : 'usd',
      rowsPerPage: const {10, 20, 50}.contains(rows) ? rows : 20,
    );
  }

  Future<void> setCurrency(String currency) async {
    final current = state.value ?? const PreferencesState();
    state = AsyncData(current.copyWith(currency: currency));
    await _preferences.setString(_currencyKey, currency);
  }

  Future<void> setRowsPerPage(int rows) async {
    final current = state.value ?? const PreferencesState();
    state = AsyncData(current.copyWith(rowsPerPage: rows));
    await _preferences.setInt(_rowsKey, rows);
  }
}

final preferencesProvider =
    AsyncNotifierProvider<PreferencesNotifier, PreferencesState>(
      PreferencesNotifier.new,
    );
