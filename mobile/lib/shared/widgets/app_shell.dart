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
    if (location.startsWith('/home/info')) return 1;
    if (location.startsWith('/home/finance')) return 2;
    if (location.startsWith('/home/calendar')) return 3;
    if (location.startsWith('/home/settings')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.dashboard);
      case 1:
        context.go(RouteNames.info);
      case 2:
        context.go(RouteNames.finance);
      case 3:
        context.go(RouteNames.calendar);
      case 4:
        context.go(RouteNames.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final index = _currentIndex(context);
    final isTaskDetail = GoRouterState.of(context).matchedLocation.contains('/home/tasks/');
    final hideNav = isTaskDetail || GoRouterState.of(context).matchedLocation.startsWith('/home/profile');

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: child,
      bottomNavigationBar: hideNav
          ? null
          : Container(
              decoration: BoxDecoration(
                color: AppColors.darkBackgroundMid,
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: index,
                onTap: (i) => _onTap(context, i),
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.darkTextTertiary,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    activeIcon: const Icon(Icons.home),
                    label: l.navHome,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.article_outlined),
                    activeIcon: const Icon(Icons.article),
                    label: l.navInfo,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.attach_money),
                    activeIcon: const Icon(Icons.monetization_on),
                    label: l.navFinance,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.calendar_today_outlined),
                    activeIcon: const Icon(Icons.calendar_today),
                    label: l.navCalendar,
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
