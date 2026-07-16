import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmail/core/errors/app_exception.dart';
import 'package:taskmail/shared/models/task_enums.dart';

const _kEnglishBriefPlaceholder =
    'Your AI brief will appear here once emails are synced.';

const _kHebrewBriefPlaceholder =
    'סיכום ה-AI שלכם יופיע כאן לאחר סנכרון המיילים.';

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
  String get appBrand;
  String get navHome;
  String get navTasks;
  String get navBrief;
  String get navSettings;
  String get navCalendar;
  String get navFinance;
  String get navInfo;

  String get searchBar;
  String get proactiveAiInsights;
  String get weatherAndInsights;
  String get yourTasksToday;
  String get quickActions;
  String get addTask;
  String get voiceRecord;
  String get takePhoto;
  String get writeMessage;
  String get comingSoon;
  String get noTasksToday;
  String weatherSummary(String temp, String period, String city);
  String get aiInsightDefault;

  String get loginTagline;
  String get continueWithGoogle;
  String get continueWithOutlook;
  String get devLogin;
  String get webUseDevLogin;
  String get googleWebOriginError;
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
  String get briefSummaryPlaceholder;

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
  String get snoozeOneHour;
  String get snoozeThreeHours;
  String get snoozeTomorrowMorning;
  String get snoozeNextWeek;

  String get filterAndSort;
  String get status;
  String get priority;
  String get category;
  String get energyLevel;
  String get sortBy;
  String get all;
  String get ascendingOrder;
  String get apply;

  String get energyMeterTitle;
  String energyMeterSummary(int used, int budget, int remaining);
  String get energyHigh;
  String get energyMedium;
  String get energyLow;
  String categoryBreakdown(int work, int errands, int health);

  String get settings;
  String get settingsTitle;
  String get searchInSettings;
  String get searchInInfo;
  String get infoTitle;
  String get financeTitle;
  String get calendarTitle;
  String get profileTitle;
  String get accountAndProfile;
  String get updateDetails;
  String get displayAndTheme;
  String get darkModeOn;
  String get choosePrimaryColor;
  String get notificationsManagement;
  String get integrations;
  String get connectExternalCalendar;
  String get securityAndPrivacy;
  String get securitySettings;
  String get aboutSection;
  String get appVersionLabel;
  String get termsOfUse;
  String get personalDetails;
  String get accountSettings;
  String get subscriptionDetails;
  String get securitySection;
  String get fullNameLabel;
  String get dateOfBirthLabel;
  String get emailLabel;
  String get usernameLabel;
  String get twoFactorLabel;
  String get expiresLabel;
  String get changePassword;
  String get connectedDevices;
  String get enabled;
  String get disabled;
  String get totalBalance;
  String get incomeLabel;
  String get expensesLabel;
  String get recentTransactions;
  String get budgetHome;
  String get budgetBusiness;
  String get monthlyBudget;
  String budgetSpentSummary(double spent, double budget);
  String budgetRemainingLabel(double remaining);
  String get savingsGoal;
  String savingsProgressSummary(double saved, double target);
  String get addTransaction;
  String get transactionTitle;
  String get transactionAmount;
  String get transactionIncome;
  String get transactionExpense;
  String get noTransactions;
  String get invalidTransaction;
  String get transactionAdded;
  String get noEventsToday;
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
  String get gmailConnectHint;
  String get whatsapp;
  String get whatsappConnectHint;
  String get whatsappPhoneLabel;
  String get connectWhatsAppButton;
  String get disconnectWhatsAppButton;
  String get whatsappLinkedSuccess;
  String get whatsappVoiceHelpTitle;
  String get whatsappVoiceHelpBody;
  String get openIntegrations;

  String assetAlertsTitle(int count);
  String get assetReminderDetails;
  String get assetTitleLabel;
  String get assetExpiryLabel;
  String get assetNotesLabel;
  String get assetUpdated;
  String get assetStatusOverdue;
  String get assetStatusUrgent;
  String get assetStatusWarning;
  String get assetStatusOk;
  String assetDaysOverdue(int days);
  String get assetDaysToday;
  String assetDaysUntil(int days);
  String get gmailWebHint;
  String get gmailDevLoginHint;
  String get connectGmailButton;
  String get disconnectGmailButton;
  String get signOutAndUseGoogle;
  String get outlookConnectedSuccess;
  String get gmailDisconnected;
  String get outlookDisconnected;
  String syncCompleteTasks(int count);
  String get syncCompleteNoTasks;

  String get networkError;
  String get sessionExpired;
  String get serverError;
  String get authFailed;
  String get storageError;

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
  String taskCategoryLabel(TaskCategory category);
  String energyLevelLabel(EnergyLevel level);
  String taskSortLabel(TaskSortField field);

  /// Maps known English brief placeholders from the API to localized text.
  String localizedBriefSummary(String summary);

  /// Returns a user-facing message for errors shown in the UI.
  String errorMessage(Object error);
}

class AppLocalizationsEn extends AppLocalizations {
  @override
  String get appTitle => 'TaskMail';
  @override
  String get appBrand => 'DAOS';

  @override
  String get navHome => 'Home';
  @override
  String get navTasks => 'Tasks';
  @override
  String get navBrief => 'Brief';
  @override
  String get navSettings => 'Settings';
  @override
  String get navCalendar => 'Calendar';
  @override
  String get navFinance => 'Finance';
  @override
  String get navInfo => 'Info';

  @override
  String get searchBar => 'Search...';
  @override
  String get proactiveAiInsights => 'Proactive AI Insights';
  @override
  String get weatherAndInsights => 'Weather & insights';
  @override
  String get yourTasksToday => 'Your tasks for today';
  @override
  String get quickActions => 'Quick Actions';
  @override
  String get addTask => 'Add task';
  @override
  String get voiceRecord => 'Voice note';
  @override
  String get takePhoto => 'Take photo';
  @override
  String get writeMessage => 'Write message';
  @override
  String get comingSoon => 'Coming soon';
  @override
  String get noTasksToday => 'No tasks for today — sync your email to get started.';
  @override
  String weatherSummary(String temp, String period, String city) =>
      '$temp, $period, $city';
  @override
  String get aiInsightDefault =>
      'Your AI assistant will optimize your schedule and highlight focus time once tasks are synced.';

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
  String get webUseDevLogin =>
      'On web, use Dev Login for UI development. Google Sign-In needs extra OAuth setup.';
  @override
  String get googleWebOriginError =>
      'Google blocked sign-in: add http://127.0.0.1:5173 and http://localhost:5173 to '
      'Authorized JavaScript origins in Google Cloud Console (Web OAuth client).';
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
  String get briefSummaryPlaceholder =>
      'Your AI brief will appear here once emails are synced.';

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
  String get snoozeOneHour => '1 hour';
  @override
  String get snoozeThreeHours => '3 hours';
  @override
  String get snoozeTomorrowMorning => 'Tomorrow 9 AM';
  @override
  String get snoozeNextWeek => 'Next week';

  @override
  String get filterAndSort => 'Filter & Sort';
  @override
  String get status => 'Status';
  @override
  String get priority => 'Priority';
  @override
  String get category => 'Category';
  @override
  String get energyLevel => 'Energy';
  @override
  String get sortBy => 'Sort by';
  @override
  String get all => 'All';
  @override
  String get ascendingOrder => 'Ascending order';
  @override
  String get apply => 'Apply';

  @override
  String get energyMeterTitle => 'Energy meter';
  @override
  String energyMeterSummary(int used, int budget, int remaining) =>
      '$used / $budget used · $remaining left';
  @override
  String get energyHigh => 'High';
  @override
  String get energyMedium => 'Medium';
  @override
  String get energyLow => 'Low';
  @override
  String categoryBreakdown(int work, int errands, int health) =>
      'Work $work · Errands $errands · Health $health';

  @override
  String get settings => 'Settings';
  @override
  String get settingsTitle => 'Settings';
  @override
  String get searchInSettings => 'Search settings...';
  @override
  String get searchInInfo => 'Search your info...';
  @override
  String get infoTitle => 'Info';
  @override
  String get financeTitle => 'Your financial status';
  @override
  String get calendarTitle => 'Your calendar';
  @override
  String get profileTitle => 'Profile';
  @override
  String get accountAndProfile => 'Account & Profile';
  @override
  String get updateDetails => 'Update details';
  @override
  String get displayAndTheme => 'Display & Theme';
  @override
  String get darkModeOn => 'Dark mode';
  @override
  String get choosePrimaryColor => 'Choose primary color';
  @override
  String get notificationsManagement => 'Manage notifications';
  @override
  String get integrations => 'Integrations';
  @override
  String get connectExternalCalendar => 'Connect external calendar';
  @override
  String get securityAndPrivacy => 'Security & Privacy';
  @override
  String get securitySettings => 'Security settings';
  @override
  String get aboutSection => 'About';
  @override
  String get appVersionLabel => 'App version 1.2.5';
  @override
  String get termsOfUse => 'Terms of use';
  @override
  String get personalDetails => 'Personal details';
  @override
  String get accountSettings => 'Account settings';
  @override
  String get subscriptionDetails => 'Subscription details';
  @override
  String get securitySection => 'Security';
  @override
  String get fullNameLabel => 'Full name';
  @override
  String get dateOfBirthLabel => 'Date of birth';
  @override
  String get emailLabel => 'Email';
  @override
  String get usernameLabel => 'Username';
  @override
  String get twoFactorLabel => 'Two-factor auth';
  @override
  String get expiresLabel => 'Expires';
  @override
  String get changePassword => 'Change password';
  @override
  String get connectedDevices => 'Connected devices';
  @override
  String get enabled => 'Enabled';
  @override
  String get disabled => 'Disabled';
  @override
  String get totalBalance => 'Total balance';
  @override
  String get incomeLabel => 'Income';
  @override
  String get expensesLabel => 'Expenses';
  @override
  String get recentTransactions => 'Recent transactions';
  @override
  String get budgetHome => 'Home';
  @override
  String get budgetBusiness => 'Business';
  @override
  String get monthlyBudget => 'Monthly budget';
  @override
  String budgetSpentSummary(double spent, double budget) =>
      '₪${spent.toStringAsFixed(0)} of ₪${budget.toStringAsFixed(0)} spent';
  @override
  String budgetRemainingLabel(double remaining) =>
      '₪${remaining.toStringAsFixed(0)} remaining this month';
  @override
  String get savingsGoal => 'Savings goal';
  @override
  String savingsProgressSummary(double saved, double target) =>
      '₪${saved.toStringAsFixed(0)} / ₪${target.toStringAsFixed(0)} saved';
  @override
  String get addTransaction => 'Add transaction';
  @override
  String get transactionTitle => 'Description';
  @override
  String get transactionAmount => 'Amount (₪)';
  @override
  String get transactionIncome => 'Income';
  @override
  String get transactionExpense => 'Expense';
  @override
  String get noTransactions => 'No transactions this month';
  @override
  String get invalidTransaction => 'Enter a valid title and amount';
  @override
  String get transactionAdded => 'Transaction added';
  @override
  String get noEventsToday => 'No events for this day';
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
  String get gmailConnectHint => 'Tap Connect Gmail to authorize inbox access.';
  @override
  String get whatsapp => 'WhatsApp';
  @override
  String get whatsappConnectHint =>
      'Link your phone, then send Hebrew voice or text messages to create tasks.';
  @override
  String get whatsappPhoneLabel => 'Mobile number';
  @override
  String get connectWhatsAppButton => 'Link WhatsApp';
  @override
  String get disconnectWhatsAppButton => 'Unlink WhatsApp';
  @override
  String get whatsappLinkedSuccess => 'WhatsApp number linked';
  @override
  String get whatsappVoiceHelpTitle => 'Voice tasks via WhatsApp';
  @override
  String get whatsappVoiceHelpBody =>
      'Link your phone in Settings → Integrations, then send a Hebrew voice note or text to your TaskMail WhatsApp bot.';
  @override
  String get openIntegrations => 'Open integrations';
  @override
  String assetAlertsTitle(int count) => 'Vehicle & insurance alerts ($count)';
  @override
  String get assetReminderDetails => 'Reminder details';
  @override
  String get assetTitleLabel => 'Title';
  @override
  String get assetExpiryLabel => 'Expiry date (YYYY-MM-DD)';
  @override
  String get assetNotesLabel => 'Notes';
  @override
  String get assetUpdated => 'Reminder updated';
  @override
  String get assetStatusOverdue => 'Overdue';
  @override
  String get assetStatusUrgent => 'Urgent';
  @override
  String get assetStatusWarning => 'Soon';
  @override
  String get assetStatusOk => 'OK';
  @override
  String assetDaysOverdue(int days) => '$days days overdue';
  @override
  String get assetDaysToday => 'Due today';
  @override
  String assetDaysUntil(int days) => 'In $days days';
  @override
  String get gmailWebHint =>
      'On web, Gmail uses a short-lived token (~1 hour). For permanent sync use the Android app.';
  @override
  String get gmailDevLoginHint =>
      'Dev Login cannot connect Gmail. Sign out and use Continue with Google with your real account.';
  @override
  String get connectGmailButton => 'Connect Gmail';
  @override
  String get disconnectGmailButton => 'Disconnect Gmail';
  @override
  String get signOutAndUseGoogle => 'Sign out & use Google';
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
  String get networkError => 'Network error. Please check your connection.';
  @override
  String get sessionExpired => 'Session expired. Please sign in again.';
  @override
  String get serverError => 'Something went wrong. Please try again.';
  @override
  String get authFailed => 'Authentication failed.';
  @override
  String get storageError => 'Local storage error.';

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
  String taskCategoryLabel(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.errands:
        return 'Errands';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.general:
        return 'General';
    }
  }

  @override
  String energyLevelLabel(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.high:
        return 'High energy';
      case EnergyLevel.medium:
        return 'Medium energy';
      case EnergyLevel.low:
        return 'Low energy';
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

  @override
  String localizedBriefSummary(String summary) {
    if (summary.isEmpty ||
        summary == _kEnglishBriefPlaceholder ||
        summary == _kHebrewBriefPlaceholder) {
      return briefSummaryPlaceholder;
    }
    return summary;
  }

  @override
  String errorMessage(Object error) {
    if (error is NetworkException) return networkError;
    if (error is UnauthorizedException) return sessionExpired;
    if (error is ServerException) return serverError;
    if (error is AuthFailureException) return authFailed;
    if (error is CacheException) return storageError;
    if (error is AppException) return error.message;
    return error.toString();
  }
}

class AppLocalizationsHe extends AppLocalizations {
  @override
  String get appTitle => 'TaskMail';
  @override
  String get appBrand => 'DAOS';

  @override
  String get navHome => 'בית';
  @override
  String get navTasks => 'משימות';
  @override
  String get navBrief => 'סיכום';
  @override
  String get navSettings => 'הגדרות';
  @override
  String get navCalendar => 'יומן';
  @override
  String get navFinance => 'כספים';
  @override
  String get navInfo => 'מידע';

  @override
  String get searchBar => 'שורת חיפוש';
  @override
  String get proactiveAiInsights => 'תובנות AI יזומות';
  @override
  String get weatherAndInsights => 'מזג אוויר ומשמעויות';
  @override
  String get yourTasksToday => 'המשימות שלך להיום';
  @override
  String get quickActions => 'פעולות מהירות';
  @override
  String get addTask => 'הוסף משימה';
  @override
  String get voiceRecord => 'הקלט קולית';
  @override
  String get takePhoto => 'צלם תמונה';
  @override
  String get writeMessage => 'רשום הודעה';
  @override
  String get comingSoon => 'בקרוב';
  @override
  String get noTasksToday => 'אין משימות להיום — סנכרנו מיילים כדי להתחיל.';
  @override
  String weatherSummary(String temp, String period, String city) =>
      '$temp, $period, $city';
  @override
  String get aiInsightDefault =>
      'ביצעתי אופטימיזציה ליומן שלך לשעות אחר הצהריים. יש פער של 15 דקות לעבודה עמוקה ב-14:30.';

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
  String get webUseDevLogin =>
      'ב-Web אפשר כניסת מפתח לפיתוח UI. ל-Google Sign-In צריך להוסיף origins ב-Google Cloud.';
  @override
  String get googleWebOriginError =>
      'Google חסם התחברות: הוסיפו http://127.0.0.1:5173 ו-http://localhost:5173 ל-'
      'Authorized JavaScript origins ב-Google Cloud Console (Web OAuth client).';
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
  String get briefSummaryPlaceholder =>
      'סיכום ה-AI שלכם יופיע כאן לאחר סנכרון המיילים.';

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
  String get snoozeOneHour => 'שעה';
  @override
  String get snoozeThreeHours => '3 שעות';
  @override
  String get snoozeTomorrowMorning => 'מחר ב-9:00';
  @override
  String get snoozeNextWeek => 'שבוע הבא';

  @override
  String get filterAndSort => 'סינון ומיון';
  @override
  String get status => 'סטטוס';
  @override
  String get priority => 'עדיפות';
  @override
  String get category => 'קטגוריה';
  @override
  String get energyLevel => 'אנרגיה';
  @override
  String get sortBy => 'מיין לפי';
  @override
  String get all => 'הכל';
  @override
  String get ascendingOrder => 'סדר עולה';
  @override
  String get apply => 'החל';

  @override
  String get energyMeterTitle => 'מדד אנרגיה';
  @override
  String energyMeterSummary(int used, int budget, int remaining) =>
      '$used / $budget בשימוש · $remaining נותר';
  @override
  String get energyHigh => 'גבוה';
  @override
  String get energyMedium => 'בינוני';
  @override
  String get energyLow => 'נמוך';
  @override
  String categoryBreakdown(int work, int errands, int health) =>
      'עבודה $work · סידורים $errands · בריאות $health';

  @override
  String get settings => 'הגדרות';
  @override
  String get settingsTitle => 'הגדרות';
  @override
  String get searchInSettings => 'חפש בהגדרות...';
  @override
  String get searchInInfo => '...חפש במידע שלך';
  @override
  String get infoTitle => 'מידע';
  @override
  String get financeTitle => 'המצב הפיננסי שלך';
  @override
  String get calendarTitle => 'היומן שלך';
  @override
  String get profileTitle => 'פרופיל';
  @override
  String get accountAndProfile => 'חשבון ופרופיל';
  @override
  String get updateDetails => 'עדכון פרטים';
  @override
  String get displayAndTheme => 'תצוגה וערכת נושא';
  @override
  String get darkModeOn => 'מצב כהה';
  @override
  String get choosePrimaryColor => 'בחירת צבע ראשי';
  @override
  String get notificationsManagement => 'ניהול התראות';
  @override
  String get integrations => 'אינטגרציות';
  @override
  String get connectExternalCalendar => 'חיבור ליומן חיצוני';
  @override
  String get securityAndPrivacy => 'אבטחה ופרטיות';
  @override
  String get securitySettings => 'הגדרות אבטחה';
  @override
  String get aboutSection => 'אודות';
  @override
  String get appVersionLabel => 'גרסת אפליקציה 1.2.5';
  @override
  String get termsOfUse => 'תנאי שימוש';
  @override
  String get personalDetails => 'פרטים אישיים';
  @override
  String get accountSettings => 'הגדרות חשבון';
  @override
  String get subscriptionDetails => 'פרטי מנוי';
  @override
  String get securitySection => 'אבטחה';
  @override
  String get fullNameLabel => 'שם מלא';
  @override
  String get dateOfBirthLabel => 'תאריך לידה';
  @override
  String get emailLabel => 'אימייל';
  @override
  String get usernameLabel => 'שם משתמש';
  @override
  String get twoFactorLabel => 'אימות דו-שלבי';
  @override
  String get expiresLabel => 'תוקף';
  @override
  String get changePassword => 'שינוי סיסמה';
  @override
  String get connectedDevices => 'התקנים מחוברים';
  @override
  String get enabled => 'מופעל';
  @override
  String get disabled => 'כבוי';
  @override
  String get totalBalance => 'סה"כ יתרה';
  @override
  String get incomeLabel => 'הכנסות';
  @override
  String get expensesLabel => 'הוצאות';
  @override
  String get recentTransactions => 'תנועות אחרונות';
  @override
  String get budgetHome => 'בית';
  @override
  String get budgetBusiness => 'עסק';
  @override
  String get monthlyBudget => 'תקציב חודשי';
  @override
  String budgetSpentSummary(double spent, double budget) =>
      '₪${spent.toStringAsFixed(0)} מתוך ₪${budget.toStringAsFixed(0)}';
  @override
  String budgetRemainingLabel(double remaining) =>
      '₪${remaining.toStringAsFixed(0)} נותרו החודש';
  @override
  String get savingsGoal => 'יעד חיסכון';
  @override
  String savingsProgressSummary(double saved, double target) =>
      '₪${saved.toStringAsFixed(0)} / ₪${target.toStringAsFixed(0)} נחסכו';
  @override
  String get addTransaction => 'הוסף תנועה';
  @override
  String get transactionTitle => 'תיאור';
  @override
  String get transactionAmount => 'סכום (₪)';
  @override
  String get transactionIncome => 'הכנסה';
  @override
  String get transactionExpense => 'הוצאה';
  @override
  String get noTransactions => 'אין תנועות החודש';
  @override
  String get invalidTransaction => 'הזינו תיאור וסכום תקינים';
  @override
  String get transactionAdded => 'התנועה נוספה';
  @override
  String get noEventsToday => 'אין אירועים ליום זה';
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
  String get gmailConnectHint => 'לחצו על "חבר Gmail" כדי לאשר גישה לתיבת המייל.';
  @override
  String get whatsapp => 'WhatsApp';
  @override
  String get whatsappConnectHint =>
      'חברו את המספר, ואז שלחו הודעת קול או טקסט בעברית ליצירת משימות.';
  @override
  String get whatsappPhoneLabel => 'מספר נייד';
  @override
  String get connectWhatsAppButton => 'חבר WhatsApp';
  @override
  String get disconnectWhatsAppButton => 'נתק WhatsApp';
  @override
  String get whatsappLinkedSuccess => 'מספר WhatsApp חובר';
  @override
  String get whatsappVoiceHelpTitle => 'משימות קוליות ב-WhatsApp';
  @override
  String get whatsappVoiceHelpBody =>
      'חברו את המספר בהגדרות → אינטגרציות, ואז שלחו הודעת קול או טקסט בעברית לבוט TaskMail.';
  @override
  String get openIntegrations => 'פתח אינטגרציות';
  @override
  String assetAlertsTitle(int count) => 'התראות רכב וביטוח ($count)';
  @override
  String get assetReminderDetails => 'פרטי תזכורת';
  @override
  String get assetTitleLabel => 'כותרת';
  @override
  String get assetExpiryLabel => 'תאריך תפוגה (YYYY-MM-DD)';
  @override
  String get assetNotesLabel => 'הערות';
  @override
  String get assetUpdated => 'התזכורת עודכנה';
  @override
  String get assetStatusOverdue => 'באיחור';
  @override
  String get assetStatusUrgent => 'דחוף';
  @override
  String get assetStatusWarning => 'בקרוב';
  @override
  String get assetStatusOk => 'תקין';
  @override
  String assetDaysOverdue(int days) => 'באיחור $days י\'';
  @override
  String get assetDaysToday => 'פג היום';
  @override
  String assetDaysUntil(int days) => 'בעוד $days י\'';
  @override
  String get gmailWebHint =>
      'ב-Web Gmail משתמש בטוקן זמני (~שעה). לסנכרון קבוע השתמשו באפליקציית Android.';
  @override
  String get gmailDevLoginHint =>
      'כניסת מפתח לא מחברת Gmail. התנתקו והתחברו עם "המשך עם Google" עם החשבון האמיתי שלכם.';
  @override
  String get connectGmailButton => 'חבר Gmail';
  @override
  String get disconnectGmailButton => 'נתק Gmail';
  @override
  String get signOutAndUseGoogle => 'התנתק והתחבר עם Google';
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
  String get networkError => 'שגיאת רשת. בדקו את החיבור לאינטרנט.';
  @override
  String get sessionExpired => 'פג תוקף ההתחברות. התחברו שוב.';
  @override
  String get serverError => 'משהו השתבש. נסו שוב.';
  @override
  String get authFailed => 'ההתחברות נכשלה.';
  @override
  String get storageError => 'שגיאה באחסון מקומי.';

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
  String taskCategoryLabel(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return 'עבודה';
      case TaskCategory.errands:
        return 'סידורים';
      case TaskCategory.health:
        return 'בריאות';
      case TaskCategory.general:
        return 'כללי';
    }
  }

  @override
  String energyLevelLabel(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.high:
        return 'אנרגיה גבוהה';
      case EnergyLevel.medium:
        return 'אנרגיה בינונית';
      case EnergyLevel.low:
        return 'אנרגיה נמוכה';
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

  @override
  String localizedBriefSummary(String summary) {
    if (summary.isEmpty ||
        summary == _kEnglishBriefPlaceholder ||
        summary == _kHebrewBriefPlaceholder) {
      return briefSummaryPlaceholder;
    }
    return summary;
  }

  @override
  String errorMessage(Object error) {
    if (error is NetworkException) return networkError;
    if (error is UnauthorizedException) return sessionExpired;
    if (error is ServerException) return serverError;
    if (error is AuthFailureException) return authFailed;
    if (error is CacheException) return storageError;
    if (error is AppException) return error.message;
    return error.toString();
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
