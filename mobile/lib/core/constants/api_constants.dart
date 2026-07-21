class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.taskmail.app/api/v1',
  );

  // Auth
  static const String authGoogle = '/auth/google';
  static const String authOutlook = '/auth/outlook';
  static const String authGoogleConnect = '/auth/google/connect';
  static const String authOutlookConnect = '/auth/outlook/connect';
  static const String authGoogleDisconnect = '/auth/google/disconnect';
  static const String authOutlookDisconnect = '/auth/outlook/disconnect';
  static const String authDev = '/auth/dev';
  static const String authRefresh = '/auth/refresh';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';
  static const String authWhatsAppLink = '/auth/whatsapp/link';
  static const String authWhatsAppDisconnect = '/auth/whatsapp/disconnect';
  static const String whatsAppSimulate = '/whatsapp/simulate';

  // Tasks
  static const String tasks = '/tasks';
  static const String tasksFromVoice = '/tasks/from-voice';

  // Dashboard & brief
  static const String dashboard = '/dashboard';
  static const String dailyBrief = '/daily-brief';

  // Hub pages
  static const String profile = '/profile';
  static const String calendar = '/calendar';
  static const String finance = '/finance';
  static const String financeTransactions = '/finance/transactions';
  static const String bankProviders = '/banks/providers';
  static const String bankConnections = '/banks/connections';
  static const String bankConnect = '/banks/connect';
  static const String infoHub = '/info';
  static const String infoDocuments = '/info/documents';
  static const String assets = '/assets';

  // Settings & notifications
  static const String settings = '/settings';
  static const String syncEmails = '/emails/sync';
  static const String registerDevice = '/notifications/device';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 90);
}
