import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daos/core/locale/locale_provider.dart';
import 'package:daos/features/auth/presentation/providers/auth_provider.dart';
import 'package:daos/features/sms/presentation/sms_sync_provider.dart';
import 'package:daos/l10n/app_localizations.dart';
import 'package:daos/routes/app_router.dart';
import 'package:daos/services/notification_service.dart';
import 'package:daos/theme/app_theme.dart';

class DaosApp extends ConsumerStatefulWidget {
  const DaosApp({super.key});

  @override
  ConsumerState<DaosApp> createState() => _DaosAppState();
}

class _DaosAppState extends ConsumerState<DaosApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(notificationServiceProvider).initialize();
        await ref.read(notificationServiceProvider).registerDeviceToken();
      } catch (_) {}
      await ref.read(smsSyncProvider.notifier).syncIfEnabled();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (prev, next) {
      if (prev?.isAuthenticated != true && next.isAuthenticated && !next.isLoading) {
        ref.read(smsSyncProvider.notifier).syncIfEnabled();
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
