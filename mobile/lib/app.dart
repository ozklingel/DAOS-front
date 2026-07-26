import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/locale/locale_provider.dart';
import 'package:taskmail/l10n/app_localizations.dart';
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
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'TaskMail',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: locale,
      localeResolutionCallback: (deviceLocale, supported) {
        if (deviceLocale != null) {
          for (final supportedLocale in supported) {
            if (supportedLocale.languageCode == deviceLocale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return const Locale('he');
      },
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
