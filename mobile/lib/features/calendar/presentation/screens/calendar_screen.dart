import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmail/features/dashboard/presentation/widgets/glass_card.dart';
import 'package:taskmail/features/hub/data/models/hub_models.dart';
import 'package:taskmail/features/hub/presentation/providers/hub_providers.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/shared/widgets/daos_page_scaffold.dart';
import 'package:taskmail/shared/widgets/hub_menu_card.dart';
import 'package:taskmail/features/info/presentation/widgets/asset_reminder_sheet.dart';
import 'package:taskmail/shared/widgets/loading_error_widgets.dart';
import 'package:taskmail/theme/app_colors.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  String? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).user;
    final calendarAsync = ref.watch(calendarProvider(_selectedDate));

    return DaosPageScaffold(
      title: l.calendarTitle,
      searchHint: l.searchBar,
      showSearch: false,
      avatarInitial: user?.name ?? user?.email,
      avatarUrl: user?.avatarUrl,
      body: calendarAsync.when(
        loading: () => const ShimmerLoading(itemCount: 4),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(calendarProvider(_selectedDate)),
        ),
        data: (calendar) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              calendar.monthLabel,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: calendar.days.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final day = calendar.days[index];
                  return _DayChip(
                    day: day,
                    onTap: () => setState(() => _selectedDate = day.date),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (calendar.events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  l.noEventsToday,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.darkTextSecondary),
                ),
              )
            else
              ...calendar.events.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CalendarEventCard(
                    event: event,
                    onTap: event.source == 'task'
                        ? () => context.push('/home/tasks/${event.id}')
                        : event.source == 'reminder'
                            ? () => _openReminder(context, ref, event.id)
                            : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openReminder(BuildContext context, WidgetRef ref, String id) async {
    final hub = await ref.read(infoHubProvider.future);
    final matches = hub.reminders.where((r) => r.id == id).toList();
    if (matches.isEmpty || !context.mounted) return;
    await showAssetReminderSheet(context, ref, matches.first);
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day, required this.onTap});

  final CalendarDayData day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = day.isSelected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.darkSurface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: day.isToday
                ? AppColors.primary.withValues(alpha: 0.8)
                : AppColors.darkGlassBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white : AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.dayNumber}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.darkTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarEventCard extends StatelessWidget {
  const _CalendarEventCard({required this.event, this.onTap});

  final CalendarEventData event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(hubIconForKey(event.icon), color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${event.startTime} - ${event.endTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
