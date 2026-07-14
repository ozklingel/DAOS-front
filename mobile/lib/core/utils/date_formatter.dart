import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDeadline(DateTime? date) {
    if (date == null) return 'No deadline';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(date.year, date.month, date.day);

    if (deadlineDay == today) {
      return 'Today ${DateFormat.jm().format(date)}';
    }
    if (deadlineDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow ${DateFormat.jm().format(date)}';
    }
    if (deadlineDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return DateFormat('MMM d, y').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
}
