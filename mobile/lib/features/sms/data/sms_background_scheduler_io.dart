import 'package:flutter/foundation.dart';
import 'package:taskmail/features/sms/data/sms_background_sync.dart';
import 'package:workmanager/workmanager.dart';

const String _kSmsSyncTaskName = 'daosSmsSyncTask';
const String _kSmsSyncUniqueName = 'daos-sms-sync';

@pragma('vm:entry-point')
void smsSyncCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _kSmsSyncTaskName && task != Workmanager.iOSBackgroundTask) {
      return true;
    }
    try {
      await syncSmsFromBackground();
    } catch (e, st) {
      debugPrint('SMS background sync failed: $e\n$st');
    }
    return true;
  });
}

class SmsBackgroundScheduler {
  static Future<void> initialize({required bool debug}) async {
    await Workmanager().initialize(
      smsSyncCallbackDispatcher,
      isInDebugMode: debug,
    );
  }

  static Future<void> schedulePeriodic() async {
    await Workmanager().registerPeriodicTask(
      _kSmsSyncUniqueName,
      _kSmsSyncTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
  }

  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_kSmsSyncUniqueName);
  }
}
