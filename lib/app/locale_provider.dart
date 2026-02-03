import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/shared_prefs_provider.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(() {
  return LocaleNotifier();
});

class LocaleNotifier extends Notifier<Locale?> {
  static const _key = 'selected_locale';

  @override
  Locale? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedLocaleStr = prefs.getString(_key);
    
    if (savedLocaleStr == null) return null; // System default
    
    return Locale(savedLocaleStr);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}
