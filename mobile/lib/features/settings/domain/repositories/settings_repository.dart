import 'package:taskmail/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<AppSettings> updateSettings(AppSettings settings);
  Future<int> syncEmails();
}
