import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/services/secure_storage_service.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadSavedLocale();
    return _deviceLocale();
  }

  Locale _deviceLocale() {
    final code = PlatformDispatcher.instance.locale.languageCode;
    if (code == 'he') return const Locale('he');
    return const Locale('en');
  }

  Future<void> _loadSavedLocale() async {
    final saved = await ref.read(secureStorageServiceProvider).getLocale();
    if (saved == 'he' || saved == 'en') {
      state = Locale(saved!);
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
