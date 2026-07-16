import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/firebase/firebase_bootstrap.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  FirebaseAnalytics? get _analytics {
    if (!isFirebaseReady) return null;
    try {
      return FirebaseAnalytics.instance;
    } catch (e) {
      debugPrint('Firebase Analytics unavailable: $e');
      return null;
    }
  }

  Future<void> _safe(Future<void> Function(FirebaseAnalytics analytics) action) async {
    final analytics = _analytics;
    if (analytics == null) return;
    try {
      await action(analytics);
    } catch (e) {
      debugPrint('Analytics event skipped: $e');
    }
  }

  Future<void> logLogin(String method) =>
      _safe((a) => a.logLogin(loginMethod: method));

  Future<void> logTaskCompleted(String taskId) => _safe(
        (a) => a.logEvent(name: 'task_completed', parameters: {'task_id': taskId}),
      );

  Future<void> logTaskSnoozed(String taskId) => _safe(
        (a) => a.logEvent(name: 'task_snoozed', parameters: {'task_id': taskId}),
      );

  Future<void> logTaskDismissed(String taskId) => _safe(
        (a) => a.logEvent(name: 'task_dismissed', parameters: {'task_id': taskId}),
      );

  Future<void> logScreenView(String screenName) =>
      _safe((a) => a.logScreenView(screenName: screenName));
}
