import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daos/features/auth/presentation/providers/auth_provider.dart';
import 'package:daos/features/auth/presentation/screens/outlook_oauth_callback_screen.dart';
import 'package:daos/features/auth/presentation/screens/login_screen.dart';
import 'package:daos/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:daos/features/daily_brief/presentation/screens/daily_brief_screen.dart';
import 'package:daos/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:daos/features/finance/presentation/screens/finance_screen.dart';
import 'package:daos/features/info/presentation/screens/info_screen.dart';
import 'package:daos/features/profile/presentation/screens/profile_screen.dart';
import 'package:daos/features/settings/presentation/screens/settings_screen.dart';
import 'package:daos/features/splash/presentation/screens/splash_screen.dart';
import 'package:daos/features/tasks/presentation/screens/task_details_screen.dart';
import 'package:daos/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:daos/routes/route_names.dart';
import 'package:daos/shared/widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Use read (not watch) so GoRouter is created once. Watching auth would
  // rebuild a new router on every notifyListeners and reset to splash,
  // which drops in-flight Google/Outlook sign-in results.
  final authState = ref.read(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: authState,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthLoading = authState.isLoading;
      final location = state.matchedLocation;

      // Keep login mounted while an OAuth picker / sign-in is in progress.
      if (isAuthLoading && location == RouteNames.login) {
        return null;
      }

      if (location == RouteNames.splash) {
        if (isAuthLoading) return null;
        return isAuthenticated ? RouteNames.dashboard : RouteNames.login;
      }

      if (!isAuthenticated &&
          location != RouteNames.login &&
          location != RouteNames.outlookOAuthCallback) {
        return RouteNames.login;
      }

      if (isAuthenticated && location == RouteNames.login) {
        return RouteNames.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.outlookOAuthCallback,
        builder: (context, state) => const OutlookOAuthCallbackScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            redirect: (_, __) => RouteNames.dashboard,
          ),
          GoRoute(
            path: RouteNames.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.tasks,
            pageBuilder: (context, state) {
              final filter = state.uri.queryParameters['filter'];
              return NoTransitionPage(
                child: TasksScreen(initialFilter: filter),
              );
            },
          ),
          GoRoute(
            path: '/home/tasks/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TaskDetailsScreen(taskId: id);
            },
          ),
          GoRoute(
            path: RouteNames.info,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InfoScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.finance,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FinanceScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.calendar,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.dailyBrief,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DailyBriefScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
