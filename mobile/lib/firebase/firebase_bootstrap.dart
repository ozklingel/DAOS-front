import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:taskmail/firebase_options.dart';

/// Set to true after [initFirebase] succeeds.
bool isFirebaseReady = false;

Future<void> initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseReady = true;
    debugPrint('Firebase initialized');
  } catch (e) {
    isFirebaseReady = false;
    debugPrint('Firebase not configured (optional for local dev): $e');
  }
}
