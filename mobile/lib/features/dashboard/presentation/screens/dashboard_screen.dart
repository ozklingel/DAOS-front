import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:taskmail/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:taskmail/routes/route_names.dart';
import 'package:taskmail/shared/widgets/loading_error_widgets.dart';
import 'package:taskmail/shared/widgets/task_card.dart';
import 'package:taskmail/theme/app_colors.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Text('Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const ShimmerLoading(itemCount: 4),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  StatCard(
                    emoji: '🔥',
                    label: 'Critical Tasks',
                    count: data.stats.criticalCount,
                    color: AppColors.critical,
                    background: AppColors.criticalBg,
                    onTap: () => context.go('${RouteNames.tasks}?filter=critical'),
                  ),
                  StatCard(
                    emoji: '📋',
                    label: 'Open Tasks',
                    count: data.stats.openCount,
                    color: AppColors.info,
                    background: AppColors.infoBg,
                    onTap: () => context.go('${RouteNames.tasks}?filter=open'),
                  ),
                  StatCard(
                    emoji: '⏰',
                    label: 'Overdue Tasks',
                    count: data.stats.overdueCount,
                    color: AppColors.warning,
                    background: AppColors.warningBg,
                    onTap: () => context.go('${RouteNames.tasks}?filter=overdue'),
                  ),
                  StatCard(
                    emoji: '✅',
                    label: 'Completed This Week',
                    count: data.stats.completedThisWeek,
                    color: AppColors.success,
                    background: AppColors.successBg,
                    onTap: () =>
                        context.go('${RouteNames.tasks}?filter=completed'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _BriefCard(summary: data.briefSummary),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'High Priority',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.go(RouteNames.tasks),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (data.recentHighPriorityTasks.isEmpty)
                const EmptyStateView(
                  title: 'All caught up',
                  subtitle: 'No high-priority tasks right now.',
                  icon: Icons.celebration_outlined,
                )
              else
                ...data.recentHighPriorityTasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TaskCard(task: task, compact: true),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _BriefCard extends StatelessWidget {
  const _BriefCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                "Today's AI Brief",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
