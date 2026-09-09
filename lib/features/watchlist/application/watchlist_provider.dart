import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistNotifier extends AsyncNotifier<Set<String>> {
  static const _key = 'coinscope:watchlist';
  final _preferences = SharedPreferencesAsync();

  @override
  Future<Set<String>> build() async {
    final ids = await _preferences.getStringList(_key) ?? const <String>[];
    return ids.toSet();
  }

  Future<void> toggle(String id) async {
    final current = state.value ?? const <String>{};
    final next = {...current};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = AsyncData(next);
    await _preferences.setStringList(_key, next.toList(growable: false));
  }
}

final watchlistProvider = AsyncNotifierProvider<WatchlistNotifier, Set<String>>(
  WatchlistNotifier.new,
);
