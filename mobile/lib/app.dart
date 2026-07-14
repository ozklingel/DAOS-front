import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/routes/app_router.dart';
import 'package:taskmail/services/notification_service.dart';
import 'package:taskmail/theme/app_theme.dart';

class TaskMailApp extends ConsumerStatefulWidget {
  const TaskMailApp({super.key});

  @override
  ConsumerState<TaskMailApp> createState() => _TaskMailAppState();
}

class _TaskMailAppState extends ConsumerState<TaskMailApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(notificationServiceProvider).initialize();
        await ref.read(notificationServiceProvider).registerDeviceToken();
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TaskMail',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
