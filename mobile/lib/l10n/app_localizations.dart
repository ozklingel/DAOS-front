import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmail/shared/models/task_enums.dart';

abstract class AppLocalizations {
  static const supportedLocales = [
    Locale('en'),
    Locale('he'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations forLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'he':
        return AppLocalizationsHe();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  String get appTitle;
  String get navHome;
  String get navTasks;
  String get navBrief;
  String get navSettings;

  String get loginTagline;
  String get continueWithGoogle;
  String get continueWithOutlook;
  String get devLogin;
  String get loginTerms;
  String get splashTagline;

  String get dashboard;
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;
  String get criticalTasks;
  String get openTasks;
  String get overdueTasks;
  String get completedThisWeek;
  String get todaysAiBrief;
  String get highPriority;
  String get seeAll;
  String get allCaughtUp;
  String get noHighPriorityTasks;

  String get tasks;
  String get searchTasks;
  String get noTasksFound;
  String get adjustFilters;

  String get dailyBrief;
  String get aiSummary;
  String get insights;
  String get highlightedTasks;

  String get taskDetails;
  String get deadline;
  String get sender;
  String get created;
  String get sourceEmail;
  String get dismiss;
  String get snooze;
  String get done;
  String get snoozeUntil;
  String snoozeOption(String label);

  String get filterAndSort;
  String get status;
  String get priority;
  String get sortBy;
  String get all;
  String get ascendingOrder;
  String get apply;

  String get settings;
  String get user;
  String get emailConnections;
  String get gmail;
  String get outlook;
  String get connected;
  String get notConnected;
  String get connect;
  String get disconnect;
  String get syncEmailsNow;
  String get notifications;
  String get pushNotifications;
  String get pushNotificationsSubtitle;
  String get dailyBriefSetting;
  String get dailyBriefSubtitle;
  String get emailSync;
  String get emailSyncSubtitle;
  String get signOut;
  String get language;
  String get english;
  String get hebrew;

  String get tryAgain;
  String get gmailConnectedSuccess;
  String get outlookConnectedSuccess;
  String get gmailDisconnected;
  String get outlookDisconnected;
  String syncCompleteTasks(int count);
  String get syncCompleteNoTasks;

  String get noDeadline;
  String get today;
  String get tomorrow;
  String get yesterday;
  String get justNow;
  String minutesAgo(int n);
  String hoursAgo(int n);
  String daysAgo(int n);

  String taskStatusLabel(TaskStatus status);
  String taskPriorityLabel(TaskPriority priority);
  String taskSortLabel(TaskSortField field);
}

class AppLocalizationsEn extends AppLocalizations {
  @override
  String get appTitle => 'TaskMail';

  @override
  String get navHome => 'Home';
  @override
  String get navTasks => 'Tasks';
  @override
  String get navBrief => 'Brief';
  @override
  String get navSettings => 'Settings';

  @override
  String get loginTagline =>
      'Turn your inbox into actionable tasks.\nAI analyzes your emails so you never miss what matters.';
  @override
  String get continueWithGoogle => 'Continue with Google';
  @override
  String get continueWithOutlook => 'Continue with Outlook';
  @override
  String get devLogin => 'Dev Login (skip OAuth)';
  @override
  String get loginTerms =>
      'By continuing, you agree to our Terms of Service\nand Privacy Policy';
  @override
  String get splashTagline => 'AI-powered email tasks';

  @override
  String get dashboard => 'Dashboard';
  @override
  String get goodMorning => 'Good morning';
  @override
  String get goodAfternoon => 'Good afternoon';
  @override
  String get goodEvening => 'Good evening';
  @override
  String get criticalTasks => 'Critical Tasks';
  @override
  String get openTasks => 'Open Tasks';
  @override
  String get overdueTasks => 'Overdue Tasks';
  @override
  String get completedThisWeek => 'Completed This Week';
  @override
  String get todaysAiBrief => "Today's AI Brief";
  @override
  String get highPriority => 'High Priority';
  @override
  String get seeAll => 'See all';
  @override
  String get allCaughtUp => 'All caught up';
  @override
  String get noHighPriorityTasks => 'No high-priority tasks right now.';

  @override
  String get tasks => 'Tasks';
  @override
  String get searchTasks => 'Search tasks...';
  @override
  String get noTasksFound => 'No tasks found';
  @override
  String get adjustFilters => 'Try adjusting your filters or search query.';

  @override
  String get dailyBrief => 'Daily Brief';
  @override
  String get aiSummary => 'AI Summary';
  @override
  String get insights => 'Insights';
  @override
  String get highlightedTasks => 'Highlighted Tasks';

  @override
  String get taskDetails => 'Task Details';
  @override
  String get deadline => 'Deadline';
  @override
  String get sender => 'Sender';
  @override
  String get created => 'Created';
  @override
  String get sourceEmail => 'Source Email';
  @override
  String get dismiss => 'Dismiss';
  @override
  String get snooze => 'Snooze';
  @override
  String get done => 'Done';
  @override
  String get snoozeUntil => 'Snooze until';
  @override
  String snoozeOption(String label) => label;

  @override
  String get filterAndSort => 'Filter & Sort';
  @override
  String get status => 'Status';
  @override
  String get priority => 'Priority';
  @override
  String get sortBy => 'Sort by';
  @override
  String get all => 'All';
  @override
  String get ascendingOrder => 'Ascending order';
  @override
  String get apply => 'Apply';

  @override
  String get settings => 'Settings';
  @override
  String get user => 'User';
  @override
  String get emailConnections => 'Email Connections';
  @override
  String get gmail => 'Gmail';
  @override
  String get outlook => 'Outlook';
  @override
  String get connected => 'Connected';
  @override
  String get notConnected => 'Not connected';
  @override
  String get connect => 'Connect';
  @override
  String get disconnect => 'Disconnect';
  @override
  String get syncEmailsNow => 'Sync emails now';
  @override
  String get notifications => 'Notifications';
  @override
  String get pushNotifications => 'Push notifications';
  @override
  String get pushNotificationsSubtitle => 'Get reminded about urgent tasks';
  @override
  String get dailyBriefSetting => 'Daily brief';
  @override
  String get dailyBriefSubtitle => 'Receive AI summary each morning';
  @override
  String get emailSync => 'Email sync';
  @override
  String get emailSyncSubtitle => 'Continuously analyze new emails';
  @override
  String get signOut => 'Sign out';
  @override
  String get language => 'Language';
  @override
  String get english => 'English';
  @override
  String get hebrew => 'Hebrew';

  @override
  String get tryAgain => 'Try Again';
  @override
  String get gmailConnectedSuccess => 'Gmail connected successfully';
  @override
  String get outlookConnectedSuccess => 'Outlook connected successfully';
  @override
  String get gmailDisconnected => 'Gmail disconnected';
  @override
  String get outlookDisconnected => 'Outlook disconnected';
  @override
  String syncCompleteTasks(int count) =>
      'Sync complete — $count new task${count == 1 ? '' : 's'} created';
  @override
  String get syncCompleteNoTasks =>
      'Sync complete — no new actionable emails found';

  @override
  String get noDeadline => 'No deadline';
  @override
  String get today => 'Today';
  @override
  String get tomorrow => 'Tomorrow';
  @override
  String get yesterday => 'Yesterday';
  @override
  String get justNow => 'Just now';
  @override
  String minutesAgo(int n) => '${n}m ago';
  @override
  String hoursAgo(int n) => '${n}h ago';
  @override
  String daysAgo(int n) => '${n}d ago';

  @override
  String taskStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.open:
        return 'Open';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.snoozed:
        return 'Snoozed';
      case TaskStatus.dismissed:
        return 'Dismissed';
      case TaskStatus.overdue:
        return 'Overdue';
    }
  }

  @override
  String taskPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return 'Critical';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.none:
        return 'None';
    }
  }

  @override
  String taskSortLabel(TaskSortField field) {
    switch (field) {
      case TaskSortField.deadline:
        return 'Deadline';
      case TaskSortField.createdAt:
        return 'Creation Date';
      case TaskSortField.priorityScore:
        return 'Priority Score';
    }
  }
}

class AppLocalizationsHe extends AppLocalizations {
  @override
  String get appTitle => 'TaskMail';

  @override
  String get navHome => 'בית';
  @override
  String get navTasks => 'משימות';
  @override
  String get navBrief => 'סיכום';
  @override
  String get navSettings => 'הגדרות';

  @override
  String get loginTagline =>
      'הפכו את תיבת הדואר למשימות ברורות.\nבינה מלאכותית מנתחת את המיילים שלכם כדי שלא תפספסו דבר.';
  @override
  String get continueWithGoogle => 'המשך עם Google';
  @override
  String get continueWithOutlook => 'המשך עם Outlook';
  @override
  String get devLogin => 'כניסת מפתח (דילוג על OAuth)';
  @override
  String get loginTerms =>
      'בהמשך השימוש, אתם מסכימים לתנאי השירות\nולמדיניות הפרטיות';
  @override
  String get splashTagline => 'משימות מייל מבוססות AI';

  @override
  String get dashboard => 'לוח בקרה';
  @override
  String get goodMorning => 'בוקר טוב';
  @override
  String get goodAfternoon => 'צהריים טובים';
  @override
  String get goodEvening => 'ערב טוב';
  @override
  String get criticalTasks => 'משימות קריטיות';
  @override
  String get openTasks => 'משימות פתוחות';
  @override
  String get overdueTasks => 'משימות באיחור';
  @override
  String get completedThisWeek => 'הושלמו השבוע';
  @override
  String get todaysAiBrief => 'סיכום AI להיום';
  @override
  String get highPriority => 'עדיפות גבוהה';
  @override
  String get seeAll => 'הצג הכל';
  @override
  String get allCaughtUp => 'הכל מעודכן';
  @override
  String get noHighPriorityTasks => 'אין משימות בעדיפות גבוהה כרגע.';

  @override
  String get tasks => 'משימות';
  @override
  String get searchTasks => 'חיפוש משימות...';
  @override
  String get noTasksFound => 'לא נמצאו משימות';
  @override
  String get adjustFilters => 'נסו לשנות את הסינון או את החיפוש.';

  @override
  String get dailyBrief => 'סיכום יומי';
  @override
  String get aiSummary => 'סיכום AI';
  @override
  String get insights => 'תובנות';
  @override
  String get highlightedTasks => 'משימות מודגשות';

  @override
  String get taskDetails => 'פרטי משימה';
  @override
  String get deadline => 'מועד אחרון';
  @override
  String get sender => 'שולח';
  @override
  String get created => 'נוצר';
  @override
  String get sourceEmail => 'מייל מקור';
  @override
  String get dismiss => 'התעלם';
  @override
  String get snooze => 'דחה';
  @override
  String get done => 'בוצע';
  @override
  String get snoozeUntil => 'דחה עד';
  @override
  String snoozeOption(String label) {
    switch (label) {
      case '1 hour':
        return 'שעה';
      case '3 hours':
        return '3 שעות';
      case 'Tomorrow 9 AM':
        return 'מחר ב-9:00';
      case 'Next week':
        return 'שבוע הבא';
      default:
        return label;
    }
  }

  @override
  String get filterAndSort => 'סינון ומיון';
  @override
  String get status => 'סטטוס';
  @override
  String get priority => 'עדיפות';
  @override
  String get sortBy => 'מיין לפי';
  @override
  String get all => 'הכל';
  @override
  String get ascendingOrder => 'סדר עולה';
  @override
  String get apply => 'החל';

  @override
  String get settings => 'הגדרות';
  @override
  String get user => 'משתמש';
  @override
  String get emailConnections => 'חיבורי דואר';
  @override
  String get gmail => 'Gmail';
  @override
  String get outlook => 'Outlook';
  @override
  String get connected => 'מחובר';
  @override
  String get notConnected => 'לא מחובר';
  @override
  String get connect => 'חבר';
  @override
  String get disconnect => 'נתק';
  @override
  String get syncEmailsNow => 'סנכרן מיילים עכשיו';
  @override
  String get notifications => 'התראות';
  @override
  String get pushNotifications => 'התראות push';
  @override
  String get pushNotificationsSubtitle => 'קבלו תזכורות על משימות דחופות';
  @override
  String get dailyBriefSetting => 'סיכום יומי';
  @override
  String get dailyBriefSubtitle => 'קבלו סיכום AI כל בוקר';
  @override
  String get emailSync => 'סנכרון מייל';
  @override
  String get emailSyncSubtitle => 'ניתוח מיילים חדשים באופן רציף';
  @override
  String get signOut => 'התנתק';
  @override
  String get language => 'שפה';
  @override
  String get english => 'English';
  @override
  String get hebrew => 'עברית';

  @override
  String get tryAgain => 'נסה שוב';
  @override
  String get gmailConnectedSuccess => 'Gmail חובר בהצלחה';
  @override
  String get outlookConnectedSuccess => 'Outlook חובר בהצלחה';
  @override
  String get gmailDisconnected => 'Gmail נותק';
  @override
  String get outlookDisconnected => 'Outlook נותק';
  @override
  String syncCompleteTasks(int count) =>
      'סנכרון הושלם — נוצר${count == 1 ? 'ה' : 'ו'} $count משימ${count == 1 ? 'ה' : 'ות'} חדש${count == 1 ? 'ה' : 'ות'}';
  @override
  String get syncCompleteNoTasks =>
      'סנכרון הושלם — לא נמצאו מיילים חדשים לטיפול';

  @override
  String get noDeadline => 'ללא מועד';
  @override
  String get today => 'היום';
  @override
  String get tomorrow => 'מחר';
  @override
  String get yesterday => 'אתמול';
  @override
  String get justNow => 'עכשיו';
  @override
  String minutesAgo(int n) => 'לפני ${n} דק\'';
  @override
  String hoursAgo(int n) => 'לפני ${n} ש\'';
  @override
  String daysAgo(int n) => 'לפני ${n} י\'';

  @override
  String taskStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.open:
        return 'פתוח';
      case TaskStatus.completed:
        return 'הושלם';
      case TaskStatus.snoozed:
        return 'נדחה';
      case TaskStatus.dismissed:
        return 'התעלם';
      case TaskStatus.overdue:
        return 'באיחור';
    }
  }

  @override
  String taskPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return 'קריטי';
      case TaskPriority.high:
        return 'גבוה';
      case TaskPriority.medium:
        return 'בינוני';
      case TaskPriority.low:
        return 'נמוך';
      case TaskPriority.none:
        return 'ללא';
    }
  }

  @override
  String taskSortLabel(TaskSortField field) {
    switch (field) {
      case TaskSortField.deadline:
        return 'מועד אחרון';
      case TaskSortField.createdAt:
        return 'תאריך יצירה';
      case TaskSortField.priorityScore:
        return 'ציון עדיפות';
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'he'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(
      AppLocalizations.forLocale(locale),
    );
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
