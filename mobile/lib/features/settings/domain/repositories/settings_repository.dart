import 'package:daos/features/settings/data/models/outlook_inbox_preview_model.dart';
import 'package:daos/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<AppSettings> updateSettings(AppSettings settings);
  Future<({int created, int scanned})> syncEmails();
  Future<OutlookInboxPreviewModel> previewOutlookInbox();
}
