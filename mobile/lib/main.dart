import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/app.dart';
import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/locale/locale_provider.dart';
import 'package:taskmail/firebase/firebase_bootstrap.dart';
import 'package:taskmail/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    debugPrint('TaskMail API: ${ApiConstants.baseUrl}');
  }

  await initFirebase();
  if (isFirebaseReady) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  final container = ProviderContainer();
  await container.read(localeProvider.notifier).ensureInitialized();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TaskMailApp(),
    ),
  );
}
