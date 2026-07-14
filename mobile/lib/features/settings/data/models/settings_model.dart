import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taskmail/features/settings/domain/entities/app_settings.dart';

part 'settings_model.freezed.dart';

@freezed
abstract class SettingsModel with _$SettingsModel {
  const SettingsModel._();

  const factory SettingsModel({
    @Default(true) bool pushNotificationsEnabled,
    @Default(true) bool dailyBriefEnabled,
    @Default(true) bool emailSyncEnabled,
    @Default('09:00') String dailyBriefTime,
    @Default('en') String language,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      pushNotificationsEnabled: json['push_notifications_enabled'] as bool? ??
          json['pushNotificationsEnabled'] as bool? ??
          true,
      dailyBriefEnabled: json['daily_brief_enabled'] as bool? ??
          json['dailyBriefEnabled'] as bool? ??
          true,
      emailSyncEnabled: json['email_sync_enabled'] as bool? ??
          json['emailSyncEnabled'] as bool? ??
          true,
      dailyBriefTime: (json['daily_brief_time'] ??
              json['dailyBriefTime'] ??
              '09:00') as String,
      language: json['language'] as String? ?? 'en',
    );
  }

  AppSettings toEntity() => AppSettings(
        pushNotificationsEnabled: pushNotificationsEnabled,
        dailyBriefEnabled: dailyBriefEnabled,
        emailSyncEnabled: emailSyncEnabled,
        dailyBriefTime: dailyBriefTime,
        language: language,
      );
}
