import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmail/features/auth/presentation/screens/outlook_oauth_callback_screen.dart';
import 'package:taskmail/features/auth/presentation/screens/login_screen.dart';
import 'package:taskmail/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:taskmail/features/daily_brief/presentation/screens/daily_brief_screen.dart';
import 'package:taskmail/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:taskmail/features/finance/presentation/screens/finance_screen.dart';
import 'package:taskmail/features/info/presentation/screens/info_screen.dart';
import 'package:taskmail/features/profile/presentation/screens/profile_screen.dart';
import 'package:taskmail/features/settings/presentation/screens/settings_screen.dart';
import 'package:taskmail/features/splash/presentation/screens/splash_screen.dart';
import 'package:taskmail/features/tasks/presentation/screens/task_details_screen.dart';
import 'package:taskmail/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:taskmail/routes/route_names.dart';
import 'package:taskmail/shared/widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: authState,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthLoading = authState.isLoading;
      final location = state.matchedLocation;

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
