import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline),
                    activeIcon: Icon(Icons.check_circle),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.auto_awesome_outlined),
                    activeIcon: Icon(Icons.auto_awesome),
                    label: 'Brief',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
    );
  }
}
