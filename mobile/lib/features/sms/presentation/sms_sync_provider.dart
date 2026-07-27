import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daos/core/network/api_client_provider.dart';
import 'package:daos/features/sms/data/sms_device_sync_service.dart';
import 'package:daos/features/sms/data/sms_ingest_models.dart';

final smsDeviceSyncServiceProvider = Provider<SmsDeviceSyncService>((ref) {
  return createSmsDeviceSyncService(ref.watch(apiClientProvider));
});

class SmsSyncUiState {
  const SmsSyncUiState({
    this.supported = false,
    this.enabled = false,
    this.hasPermission = false,
    this.isBusy = false,
    this.lastResult,
    this.error,
  });

  final bool supported;
  final bool enabled;
  final bool hasPermission;
  final bool isBusy;
  final SmsIngestResult? lastResult;
  final String? error;

  SmsSyncUiState copyWith({
    bool? supported,
    bool? enabled,
    bool? hasPermission,
    bool? isBusy,
    SmsIngestResult? lastResult,
    String? error,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return SmsSyncUiState(
      supported: supported ?? this.supported,
      enabled: enabled ?? this.enabled,
      hasPermission: hasPermission ?? this.hasPermission,
      isBusy: isBusy ?? this.isBusy,
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SmsSyncNotifier extends StateNotifier<SmsSyncUiState> {
  SmsSyncNotifier(this._service) : super(const SmsSyncUiState()) {
    refresh();
  }

  final SmsDeviceSyncService _service;

  Future<void> refresh() async {
    final supported = await _service.isAndroidSupported();
    final enabled = await _service.isEnabled();
    final hasPermission = await _service.hasPermission();
    state = state.copyWith(
      supported: supported,
      enabled: enabled,
      hasPermission: hasPermission,
      clearError: true,
    );
  }

  Future<void> enableAndSync() async {
    state = state.copyWith(isBusy: true, clearError: true, clearResult: true);
    try {
      final ok = await _service.ensurePermission();
      if (!ok) {
        state = state.copyWith(
          isBusy: false,
          hasPermission: false,
          error: 'sms_permission_denied',
        );
        return;
      }
      await _service.setEnabled(true);
      await _service.clearSyncedIds();
      final result = await _service.syncToday();
      state = state.copyWith(
        isBusy: false,
        enabled: true,
        hasPermission: true,
        lastResult: result,
      );
    } catch (e) {
      state = state.copyWith(isBusy: false, error: e.toString());
    }
  }

  Future<void> disable() async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await _service.setEnabled(false);
      state = state.copyWith(isBusy: false, enabled: false);
    } catch (e) {
      state = state.copyWith(isBusy: false, error: e.toString());
    }
  }

  Future<void> syncNow() async {
    state = state.copyWith(isBusy: true, clearError: true, clearResult: true);
    try {
      final ok = await _service.ensurePermission();
      if (!ok) {
        state = state.copyWith(
          isBusy: false,
          hasPermission: false,
          error: 'sms_permission_denied',
        );
        return;
      }
      final result = await _service.syncToday();
      state = state.copyWith(
        isBusy: false,
        enabled: true,
        hasPermission: true,
        lastResult: result,
      );
    } catch (e) {
      state = state.copyWith(isBusy: false, error: e.toString());
    }
  }

  /// App open / after login: POST today's SMS → server creates tasks.
  Future<void> syncTodaysInbox() async {
    if (!await _service.isAndroidSupported()) return;
    try {
      final result = await _service.syncTodaysOnLaunch();
      if (result == null) return;
      state = state.copyWith(
        enabled: true,
        hasPermission: true,
        lastResult: result,
      );
      debugPrint(
        'SMS launch sync: processed=${result.processed} created=${result.createdCount}',
      );
    } catch (e) {
      debugPrint('SMS launch sync failed: $e');
    }
  }

  /// Called after login / app start when SMS sync was already enabled.
  Future<void> syncIfEnabled() async {
    await syncTodaysInbox();
  }
}

final smsSyncProvider =
    StateNotifierProvider<SmsSyncNotifier, SmsSyncUiState>((ref) {
  return SmsSyncNotifier(ref.watch(smsDeviceSyncServiceProvider));
});
