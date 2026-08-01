import 'package:daos/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<AppSettings> updateSettings(AppSettings settings);
  Future<({int created, int scanned})> syncEmails();
}
