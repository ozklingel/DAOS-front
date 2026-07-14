import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(true) bool pushNotificationsEnabled,
    @Default(true) bool dailyBriefEnabled,
    @Default(true) bool emailSyncEnabled,
    @Default('09:00') String dailyBriefTime,
    @Default('en') String language,
  }) = _AppSettings;
}
