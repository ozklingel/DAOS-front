import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/routes/route_names.dart';
import 'package:taskmail/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home/tasks')) return 1;
    if (location.startsWith('/home/brief')) return 2;
    if (location.startsWith('/home/settings')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.dashboard);
      case 1:
        context.go(RouteNames.tasks);
      case 2:
        context.go(RouteNames.dailyBrief);
      case 3:
        context.go(RouteNames.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final index = _currentIndex(context);
    final isTaskDetail = GoRouterState.of(context).matchedLocation.contains('/home/tasks/');

    return Scaffold(
      body: child,
      bottomNavigationBar: isTaskDetail
          ? null
          : Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: BottomNavigationBar(
                currentIndex: index,
                onTap: (i) => _onTap(context, i),
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.dashboard_outlined),
                    activeIcon: const Icon(Icons.dashboard),
                    label: l.navHome,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.check_circle_outline),
                    activeIcon: const Icon(Icons.check_circle),
                    label: l.navTasks,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.auto_awesome_outlined),
                    activeIcon: const Icon(Icons.auto_awesome),
                    label: l.navBrief,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings_outlined),
                    activeIcon: const Icon(Icons.settings),
                    label: l.navSettings,
                  ),
                ],
              ),
            ),
    );
  }
}
