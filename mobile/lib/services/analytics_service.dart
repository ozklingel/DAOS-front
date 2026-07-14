import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(FirebaseAnalytics.instance);
});

class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  Future<void> logLogin(String method) =>
      _analytics.logLogin(loginMethod: method);

  Future<void> logTaskCompleted(String taskId) =>
      _analytics.logEvent(name: 'task_completed', parameters: {'task_id': taskId});

  Future<void> logTaskSnoozed(String taskId) =>
      _analytics.logEvent(name: 'task_snoozed', parameters: {'task_id': taskId});

  Future<void> logTaskDismissed(String taskId) =>
      _analytics.logEvent(name: 'task_dismissed', parameters: {'task_id': taskId});

  Future<void> logScreenView(String screenName) =>
      _analytics.logScreenView(screenName: screenName);
}
