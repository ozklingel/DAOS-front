import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/di/providers.dart';
import 'package:taskmail/features/settings/domain/entities/app_settings.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    return ref.read(settingsRepositoryProvider).getSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).updateSettings(settings),
    );
  }
}
