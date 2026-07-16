import 'package:intl/intl.dart';
import 'package:taskmail/l10n/app_localizations.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDeadline(DateTime? date, AppLocalizations l, {String? locale}) {
    if (date == null) return l.noDeadline;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(date.year, date.month, date.day);
    final time = DateFormat.jm(locale).format(date);

    if (deadlineDay == today) {
      return '${l.today} $time';
    }
    if (deadlineDay == today.add(const Duration(days: 1))) {
      return '${l.tomorrow} $time';
    }
    if (deadlineDay == today.subtract(const Duration(days: 1))) {
      return l.yesterday;
    }
    return DateFormat.yMMMd(locale).format(date);
  }

  static String formatRelative(
    DateTime date,
    AppLocalizations l, {
    String? locale,
  }) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return l.justNow;
    if (diff.inHours < 1) return l.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l.daysAgo(diff.inDays);
    return DateFormat.MMMd(locale).format(date);
  }
}
