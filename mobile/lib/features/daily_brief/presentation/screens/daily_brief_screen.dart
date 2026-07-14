import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/utils/date_formatter.dart';
import 'package:taskmail/features/daily_brief/presentation/providers/daily_brief_provider.dart';
import 'package:taskmail/shared/widgets/loading_error_widgets.dart';
import 'package:taskmail/shared/widgets/task_card.dart';
import 'package:taskmail/theme/app_colors.dart';

class DailyBriefScreen extends ConsumerWidget {
  const DailyBriefScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final briefAsync = ref.watch(dailyBriefProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Brief')),
      body: briefAsync.when(
        loading: () => const ShimmerLoading(itemCount: 2),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(dailyBriefProvider.notifier).refresh(),
        ),
        data: (brief) => RefreshIndicator(
          onRefresh: () => ref.read(dailyBriefProvider.notifier).refresh(),
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.accent.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'AI Summary',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.primary,
                                  ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormatter.formatRelative(brief.generatedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      brief.summary,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      brief.content,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                    ),
                  ],
                ),
              ),
              if (brief.insights.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text('Insights', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...brief.insights.map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            insight,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (brief.highlightedTasks.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  'Highlighted Tasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...brief.highlightedTasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TaskCard(task: task),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
