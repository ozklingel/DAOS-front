import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/network/api_client_provider.dart';
import 'package:taskmail/features/sms/data/sms_device_sync_service.dart';
import 'package:taskmail/features/sms/data/sms_ingest_models.dart';

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
      final result = await _service.syncRecent();
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
      final result = await _service.syncRecent();
      state = state.copyWith(
        isBusy: false,
        hasPermission: true,
        lastResult: result,
      );
    } catch (e) {
      state = state.copyWith(isBusy: false, error: e.toString());
    }
  }

  Future<void> pasteAndIngest(String text) async {
    state = state.copyWith(isBusy: true, clearError: true, clearResult: true);
    try {
      final result = await _service.ingestManualText(text);
      state = state.copyWith(isBusy: false, lastResult: result);
    } catch (e) {
      state = state.copyWith(isBusy: false, error: e.toString());
    }
  }
}

final smsSyncProvider =
    StateNotifierProvider<SmsSyncNotifier, SmsSyncUiState>((ref) {
  return SmsSyncNotifier(ref.watch(smsDeviceSyncServiceProvider));
});
