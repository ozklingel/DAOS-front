import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daos/core/locale/locale_provider.dart';
import 'package:daos/features/auth/presentation/providers/auth_provider.dart';
import 'package:daos/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:daos/features/hub/presentation/providers/hub_providers.dart';
import 'package:daos/features/settings/presentation/providers/settings_provider.dart';
import 'package:daos/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:daos/l10n/app_localizations.dart';
import 'package:daos/routes/app_router.dart';
import 'package:daos/services/notification_service.dart';
import 'package:daos/theme/app_theme.dart';

/// Web has no FCM — poll mail + refresh UI while the tab is open.
const _webIngestPollInterval = Duration(minutes: 2);

class DaosApp extends ConsumerStatefulWidget {
  const DaosApp({super.key});

  @override
  ConsumerState<DaosApp> createState() => _DaosAppState();
}

class _DaosAppState extends ConsumerState<DaosApp> with WidgetsBindingObserver {
  Timer? _webIngestPoll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(notificationServiceProvider).initialize();
      } catch (_) {}
      await _onAuthenticatedStartup();
      _startWebIngestPoll();
    });
  }

  @override
  void dispose() {
    _webIngestPoll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!kIsWeb) return;
    if (state == AppLifecycleState.resumed) {
      _startWebIngestPoll();
      unawaited(_syncEmailsOnAppEntry());
    } else if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _webIngestPoll?.cancel();
    }
  }

  void _startWebIngestPoll() {
    if (!kIsWeb) return;
    _webIngestPoll?.cancel();
    _webIngestPoll = Timer.periodic(_webIngestPollInterval, (_) {
      if (!mounted) return;
      final auth = ref.read(authStateProvider);
      if (!auth.isAuthenticated || auth.isLoading) return;
      unawaited(_webIngestTick());
    });
  }

  Future<void> _webIngestTick() async {
    try {
      await ref.read(settingsProvider.notifier).syncEmailsAndRefresh();
    } catch (_) {}
    // WhatsApp tasks arrive via server webhooks — refresh lists even if mail sync skipped.
    ref.invalidate(dashboardProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(infoHubProvider);
    ref.invalidate(tasksListProvider);
  }

  Future<void> _onAuthenticatedStartup() async {
    final auth = ref.read(authStateProvider);
    if (!auth.isAuthenticated || auth.isLoading) return;
    try {
      await ref.read(notificationServiceProvider).registerDeviceToken();
    } catch (_) {}
    await _syncEmailsOnAppEntry();
  }

  Future<void> _syncEmailsOnAppEntry() async {
    try {
      await ref.read(settingsProvider.future);
    } catch (_) {
      return;
    }
    try {
      await ref.read(settingsProvider.notifier).syncEmailsAndRefresh();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (prev, next) {
      final becameReady = next.isAuthenticated &&
          !next.isLoading &&
          (prev?.isAuthenticated != true || prev?.isLoading == true);
      if (becameReady) {
        unawaited(_onAuthenticatedStartup());
        _startWebIngestPoll();
      }
      if (prev?.isAuthenticated == true && !next.isAuthenticated) {
        _webIngestPoll?.cancel();
      }
    });
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'DAOS',
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
