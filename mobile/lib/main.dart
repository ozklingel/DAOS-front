import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:daos/app.dart';
import 'package:daos/core/constants/api_constants.dart';
import 'package:daos/core/locale/locale_provider.dart';
import 'package:daos/firebase/firebase_bootstrap.dart';
import 'package:daos/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Path URLs (not hash) so Azure Outlook redirect /oauth/outlook?code=... works.
  usePathUrlStrategy();

  if (kDebugMode) {
    debugPrint('DAOS API: ${ApiConstants.baseUrl}');
  }

  // Bound Firebase so a hang cannot leave a true black screen before first frame.
  try {
    await initFirebase().timeout(const Duration(seconds: 6));
  } catch (e) {
    debugPrint('Firebase init failed/timed out: $e');
  }
  if (isFirebaseReady) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  final container = ProviderContainer();
  // Show UI immediately — do not await secure-storage locale before first frame.
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DaosApp(),
    ),
  );

  try {
    await container
        .read(localeProvider.notifier)
        .ensureInitialized()
        .timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('Locale init failed/timed out: $e');
  }
}
