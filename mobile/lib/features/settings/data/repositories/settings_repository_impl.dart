import 'package:taskmail/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:taskmail/features/settings/domain/entities/app_settings.dart';
import 'package:taskmail/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._remote);

  final SettingsRemoteDataSource _remote;

  @override
  Future<AppSettings> getSettings() async {
    final model = await _remote.getSettings();
    return model.toEntity();
  }

  @override
  Future<AppSettings> updateSettings(AppSettings settings) async {
    final model = await _remote.updateSettings({
      'pushNotificationsEnabled': settings.pushNotificationsEnabled,
      'dailyBriefEnabled': settings.dailyBriefEnabled,
      'emailSyncEnabled': settings.emailSyncEnabled,
      'dailyBriefTime': settings.dailyBriefTime,
      'language': settings.language,
    });
    return model.toEntity();
  }

  @override
  Future<int> syncEmails() => _remote.syncEmails();
}
