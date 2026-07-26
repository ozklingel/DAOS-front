import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/network/api_client_provider.dart';
import 'package:taskmail/features/sms/data/sms_device_sync_service.dart';
import 'package:taskmail/features/sms/data/sms_ingest_models.dart';

final smsDeviceSyncServiceProvider = Provider<SmsDeviceSyncService>((ref) {
  return createSmsDeviceSyncService(ref.watch(apiClientProvider));
});

class SmsSyncState {
  const SmsSyncState({
    this.enabled = false,
    this.isAndroid = false,
    this.hasPermission = false,
    this.isSyncing = false,
    this.lastResult,
    this.error,
  });

  final bool enabled;
  final bool isAndroid;
  final bool hasPermission;
  final bool isSyncing;
  final SmsIngestResult? lastResult;
  final String? error;

  SmsSyncState copyWith({
    bool? enabled,
    bool? isAndroid,
    bool? hasPermission,
    bool? isSyncing,
    SmsIngestResult? lastResult,
    String? error,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return SmsSyncState(
      enabled: enabled ?? this.enabled,
      isAndroid: isAndroid ?? this.isAndroid,
      hasPermission: hasPermission ?? this.hasPermission,
      isSyncing: isSyncing ?? this.isSyncing,
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final smsSyncProvider =
    StateNotifierProvider<SmsSyncController, SmsSyncState>((ref) {
  return SmsSyncController(ref.watch(smsDeviceSyncServiceProvider));
});

class SmsSyncController extends StateNotifier<SmsSyncState> {
  SmsSyncController(this._service) : super(const SmsSyncState()) {
    refresh();
  }

  final SmsDeviceSyncService _service;

  Future<void> refresh() async {
    final android = await _service.isAndroidSupported();
    final enabled = await _service.isEnabled();
    final hasPerm = await _service.hasPermission();
    state = state.copyWith(
      isAndroid: android,
      enabled: enabled,
      hasPermission: hasPerm,
      clearError: true,
    );
  }

  Future<void> enable() async {
    state = state.copyWith(isSyncing: true, clearError: true);
    try {
      final android = await _service.isAndroidSupported();
      if (android) {
        final ok = await _service.ensurePermission();
        if (!ok) {
          state = state.copyWith(
            isSyncing: false,
            error: 'SMS_PERMISSION_DENIED',
            hasPermission: false,
          );
          return;
        }
        state = state.copyWith(hasPermission: true);
      }
      await _service.setEnabled(true);
      state = state.copyWith(enabled: true, isSyncing: false);
      if (android) {
        await syncNow();
      }
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }

  Future<void> disable() async {
    await _service.setEnabled(false);
    state = state.copyWith(enabled: false, clearResult: true);
  }

  Future<SmsIngestResult?> syncNow() async {
    state = state.copyWith(isSyncing: true, clearError: true);
    try {
      if (!await _service.isAndroidSupported()) {
        state = state.copyWith(
          isSyncing: false,
          error: 'SMS_ANDROID_ONLY_AUTO',
        );
        return null;
      }
      final ok = await _service.ensurePermission();
      if (!ok) {
        state = state.copyWith(
          isSyncing: false,
          error: 'SMS_PERMISSION_DENIED',
        );
        return null;
      }
      final result = await _service.syncRecent();
      await _service.setEnabled(true);
      state = state.copyWith(
        isSyncing: false,
        lastResult: result,
        enabled: true,
        hasPermission: true,
      );
      return result;
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
      rethrow;
    }
  }

  Future<SmsIngestResult?> ingestPaste(String text) async {
    state = state.copyWith(isSyncing: true, clearError: true);
    try {
      final result = await _service.ingestManualText(text);
      await _service.setEnabled(true);
      state = state.copyWith(
        isSyncing: false,
        lastResult: result,
        enabled: true,
      );
      return result;
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
      rethrow;
    }
  }
}
