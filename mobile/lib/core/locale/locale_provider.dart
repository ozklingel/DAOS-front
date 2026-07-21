import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/services/secure_storage_service.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  static const defaultLocale = Locale('he');

  @override
  Locale build() {
    return defaultLocale;
  }

  /// Loads persisted locale before the first frame (call from main).
  Future<void> ensureInitialized() async {
    final saved = await ref.read(secureStorageServiceProvider).getLocale();
    if (saved == 'he' || saved == 'en') {
      state = Locale(saved!);
    } else {
      state = defaultLocale;
    }
  }

  Future<void> setLocale(String languageCode, {bool persist = true}) async {
    if (languageCode != 'en' && languageCode != 'he') return;
    state = Locale(languageCode);
    if (persist) {
      await ref.read(secureStorageServiceProvider).saveLocale(languageCode);
    }
  }
}
