import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/core/di/providers.dart';
import 'package:taskmail/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmail/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:taskmail/features/dashboard/presentation/widgets/weather_card.dart';
import 'package:taskmail/features/dashboard/presentation/widgets/glass_card.dart';
import 'package:taskmail/features/tasks/domain/entities/task.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/routes/route_names.dart';
import 'package:taskmail/shared/models/task_enums.dart';
import 'package:taskmail/shared/widgets/task_meta_chips.dart';
import 'package:taskmail/features/info/presentation/screens/info_screen.dart';
import 'package:taskmail/shared/widgets/loading_error_widgets.dart';
import 'package:taskmail/theme/app_colors.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final dashboardAsync = ref.watch(dashboardProvider);
    final tasksAsync = ref.watch(todayTasksProvider);
    final user = ref.watch(authStateProvider).user;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkBackgroundGradient),
      child: SafeArea(
        child: dashboardAsync.when(
          loading: () => const ShimmerLoading(itemCount: 4),
          error: (e, _) => ErrorView(
            error: e,
            onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
          ),
          data: (data) => RefreshIndicator(
            onRefresh: () async {
              await ref.read(dashboardProvider.notifier).refresh();
              ref.invalidate(todayTasksProvider);
            },
            color: AppColors.primary,
            backgroundColor: AppColors.darkSurface,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _Header(userName: user?.name, userEmail: user?.email),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _AiInsightsCard(
                        title: l.proactiveAiInsights,
                        body: l.localizedBriefSummary(data.briefSummary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: const WeatherCard(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.yourTasksToday,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkTextPrimary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      tasksAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (_, __) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            l.noTasksToday,
                            style: const TextStyle(color: AppColors.darkTextSecondary),
                          ),
                        ),
                        data: (tasks) {
                          if (tasks.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                l.noTasksToday,
                                style: const TextStyle(
                                  color: AppColors.darkTextSecondary,
                                  height: 1.4,
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: tasks
                                .map(
                                  (task) => _TodayTaskRow(
                                    task: task,
                                    onToggle: () => _toggleTask(ref, task),
                                    onTap: () => context.push(
                                      '/home/tasks/${task.id}',
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const AssetAlertsDashboardCard(),
                Text(
                  l.quickActions,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                _QuickActions(
                  l: l,
                  onAddTask: () => context.go(RouteNames.tasks),
                  onWhatsAppHelp: () => _showWhatsAppHelp(context, l),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWhatsAppHelp(BuildContext context, AppLocalizations l) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.whatsappVoiceHelpTitle),
        content: Text(l.whatsappVoiceHelpBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.apply)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(RouteNames.settings);
            },
            child: Text(l.openIntegrations),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTask(WidgetRef ref, Task task) async {
    final repo = ref.read(tasksRepositoryProvider);
    if (task.status == TaskStatus.completed) return;
    await repo.completeTask(task.id);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(dashboardProvider);
  }
}

class _Header extends StatelessWidget {
  const _Header({this.userName, this.userEmail});

  final String? userName;
  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final initial = (userName ?? userEmail ?? 'U').substring(0, 1).toUpperCase();

    return Row(
      children: [
        GestureDetector(
          onTap: () => context.push(RouteNames.profile),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.25),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            readOnly: true,
            onTap: () => context.go(RouteNames.tasks),
            decoration: InputDecoration(
              hintText: l.searchBar,
              prefixIcon: const Icon(Icons.search, color: AppColors.darkTextTertiary),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _AiInsightsCard extends StatelessWidget {
  const _AiInsightsCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.darkTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayTaskRow extends StatelessWidget {
  const _TodayTaskRow({
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.completed;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.darkTextPrimary,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.darkTextTertiary,
                ),
              ),
            ),
            CategoryChip(category: task.category),
            const SizedBox(width: 4),
            EnergyChip(level: task.energyLevel),
            const SizedBox(width: 4),
            Checkbox(
              value: isDone,
              onChanged: isDone ? null : (_) => onToggle(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.l,
    required this.onAddTask,
    required this.onWhatsAppHelp,
  });

  final AppLocalizations l;
  final VoidCallback onAddTask;
  final VoidCallback onWhatsAppHelp;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (l.writeMessage, Icons.chat_bubble_outline, false),
      (l.takePhoto, Icons.photo_camera_outlined, false),
      (l.voiceRecord, Icons.mic_none, false),
      (l.addTask, Icons.add, true),
    ];

    return Row(
      children: actions.map((action) {
        final (label, icon, isPrimary) = action;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isPrimary
                    ? onAddTask
                    : (label == l.voiceRecord || label == l.writeMessage)
                        ? onWhatsAppHelp
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.comingSoon)),
                            );
                          },
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: isPrimary
                        ? AppColors.quickActionPrimaryGradient
                        : AppColors.quickActionGradient,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPrimary
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.darkGlassBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 22),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
