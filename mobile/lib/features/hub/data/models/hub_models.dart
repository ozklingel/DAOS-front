class ProfileData {
  const ProfileData({
    required this.id,
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.username,
    required this.twoFactorEnabled,
    required this.subscriptionPlan,
    required this.subscriptionExpires,
    this.avatarUrl,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      email: json['email'] as String,
      dateOfBirth: json['date_of_birth'] as String? ?? json['dateOfBirth'] as String? ?? '',
      username: json['username'] as String,
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? json['twoFactorEnabled'] as bool? ?? false,
      subscriptionPlan: json['subscription_plan'] as String? ?? json['subscriptionPlan'] as String? ?? '',
      subscriptionExpires: json['subscription_expires'] as String? ?? json['subscriptionExpires'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String dateOfBirth;
  final String username;
  final bool twoFactorEnabled;
  final String subscriptionPlan;
  final String subscriptionExpires;
  final String? avatarUrl;
}

class CalendarDayData {
  const CalendarDayData({
    required this.date,
    required this.dayNumber,
    required this.isToday,
    required this.isSelected,
    required this.label,
  });

  factory CalendarDayData.fromJson(Map<String, dynamic> json) {
    return CalendarDayData(
      date: json['date'] as String,
      dayNumber: json['day_number'] as int? ?? json['dayNumber'] as int? ?? 0,
      isToday: json['is_today'] as bool? ?? json['isToday'] as bool? ?? false,
      isSelected: json['is_selected'] as bool? ?? json['isSelected'] as bool? ?? false,
      label: json['label'] as String,
    );
  }

  final String date;
  final int dayNumber;
  final bool isToday;
  final bool isSelected;
  final String label;
}

class CalendarEventData {
  const CalendarEventData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.icon,
    required this.source,
  });

  factory CalendarEventData.fromJson(Map<String, dynamic> json) {
    return CalendarEventData(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String,
      startTime: json['start_time'] as String? ?? json['startTime'] as String? ?? '',
      endTime: json['end_time'] as String? ?? json['endTime'] as String? ?? '',
      icon: json['icon'] as String,
      source: json['source'] as String? ?? '',
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String startTime;
  final String endTime;
  final String icon;
  final String source;
}

class CalendarData {
  const CalendarData({
    required this.selectedDate,
    required this.monthLabel,
    required this.days,
    required this.events,
  });

  factory CalendarData.fromJson(Map<String, dynamic> json) {
    return CalendarData(
      selectedDate: json['selected_date'] as String? ?? json['selectedDate'] as String? ?? '',
      monthLabel: json['month_label'] as String? ?? json['monthLabel'] as String? ?? '',
      days: (json['days'] as List<dynamic>? ?? [])
          .map((e) => CalendarDayData.fromJson(e as Map<String, dynamic>))
          .toList(),
      events: (json['events'] as List<dynamic>? ?? [])
          .map((e) => CalendarEventData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String selectedDate;
  final String monthLabel;
  final List<CalendarDayData> days;
  final List<CalendarEventData> events;
}

class FinanceTransactionData {
  const FinanceTransactionData({
    required this.id,
    required this.title,
    required this.time,
    required this.amount,
    required this.icon,
    this.budgetType = 'home',
    this.category = 'general',
    this.txType = 'expense',
  });

  factory FinanceTransactionData.fromJson(Map<String, dynamic> json) {
    return FinanceTransactionData(
      id: json['id'] as String,
      title: json['title'] as String,
      time: json['time'] as String,
      amount: (json['amount'] as num).toDouble(),
      icon: json['icon'] as String,
      budgetType: json['budget_type'] as String? ?? json['budgetType'] as String? ?? 'home',
      category: json['category'] as String? ?? 'general',
      txType: json['tx_type'] as String? ?? json['txType'] as String? ?? 'expense',
    );
  }

  final String id;
  final String title;
  final String time;
  final double amount;
  final String icon;
  final String budgetType;
  final String category;
  final String txType;
}

class BudgetSummaryData {
  const BudgetSummaryData({
    required this.budgetType,
    required this.income,
    required this.expenses,
    required this.balance,
    required this.expenseBudget,
    required this.budgetRemaining,
    required this.savingsTarget,
    required this.savingsSaved,
    required this.savingsProgress,
  });

  factory BudgetSummaryData.fromJson(Map<String, dynamic> json) {
    return BudgetSummaryData(
      budgetType: json['budget_type'] as String? ?? json['budgetType'] as String? ?? 'home',
      income: (json['income'] as num? ?? 0).toDouble(),
      expenses: (json['expenses'] as num? ?? 0).toDouble(),
      balance: (json['balance'] as num? ?? 0).toDouble(),
      expenseBudget: (json['expense_budget'] as num? ?? json['expenseBudget'] as num? ?? 0).toDouble(),
      budgetRemaining: (json['budget_remaining'] as num? ?? json['budgetRemaining'] as num? ?? 0).toDouble(),
      savingsTarget: (json['savings_target'] as num? ?? json['savingsTarget'] as num? ?? 0).toDouble(),
      savingsSaved: (json['savings_saved'] as num? ?? json['savingsSaved'] as num? ?? 0).toDouble(),
      savingsProgress: (json['savings_progress'] as num? ?? json['savingsProgress'] as num? ?? 0).toDouble(),
    );
  }

  final String budgetType;
  final double income;
  final double expenses;
  final double balance;
  final double expenseBudget;
  final double budgetRemaining;
  final double savingsTarget;
  final double savingsSaved;
  final double savingsProgress;
}

class FinanceData {
  const FinanceData({
    required this.totalBalance,
    required this.currency,
    required this.income,
    required this.expenses,
    required this.transactions,
    required this.month,
    required this.monthLabel,
    required this.selectedType,
    required this.home,
    required this.business,
    required this.summary,
    this.bankAccounts = const [],
    this.bankTotalBalance = 0,
  });

  factory FinanceData.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] as Map<String, dynamic>?;
    final homeJson = json['home'] as Map<String, dynamic>?;
    final businessJson = json['business'] as Map<String, dynamic>?;
    return FinanceData(
      totalBalance: (json['total_balance'] as num? ?? json['totalBalance'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'ILS',
      income: (json['income'] as num? ?? summaryJson?['income'] as num? ?? 0).toDouble(),
      expenses: (json['expenses'] as num? ?? summaryJson?['expenses'] as num? ?? 0).toDouble(),
      month: json['month'] as String? ?? '',
      monthLabel: json['month_label'] as String? ?? json['monthLabel'] as String? ?? '',
      selectedType: json['selected_type'] as String? ?? json['selectedType'] as String? ?? 'home',
      home: homeJson != null
          ? BudgetSummaryData.fromJson(homeJson)
          : BudgetSummaryData.fromJson(summaryJson ?? const {}),
      business: businessJson != null
          ? BudgetSummaryData.fromJson(businessJson)
          : BudgetSummaryData.fromJson(summaryJson ?? const {}),
      summary: BudgetSummaryData.fromJson(summaryJson ?? const {}),
      transactions: (json['transactions'] as List<dynamic>? ?? [])
          .map((e) => FinanceTransactionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      bankAccounts: (json['bank_accounts'] as List<dynamic>? ?? json['bankAccounts'] as List<dynamic>? ?? [])
          .map((e) => BankAccountData.fromJson(e as Map<String, dynamic>))
          .toList(),
      bankTotalBalance:
          (json['bank_total_balance'] as num? ?? json['bankTotalBalance'] as num? ?? 0).toDouble(),
    );
  }

  final double totalBalance;
  final String currency;
  final double income;
  final double expenses;
  final List<FinanceTransactionData> transactions;
  final String month;
  final String monthLabel;
  final String selectedType;
  final BudgetSummaryData home;
  final BudgetSummaryData business;
  final BudgetSummaryData summary;
  final List<BankAccountData> bankAccounts;
  final double bankTotalBalance;
}

class BankAccountData {
  const BankAccountData({
    required this.id,
    required this.connectionId,
    required this.providerCode,
    required this.providerName,
    required this.name,
    required this.balance,
    this.accountType = 'checking',
    this.currency = 'ILS',
    this.ibanMasked,
    this.budgetType = 'home',
  });

  factory BankAccountData.fromJson(Map<String, dynamic> json) {
    return BankAccountData(
      id: json['id'] as String,
      connectionId: json['connection_id'] as String? ?? json['connectionId'] as String? ?? '',
      providerCode: json['provider_code'] as String? ?? json['providerCode'] as String? ?? '',
      providerName: json['provider_name'] as String? ?? json['providerName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      accountType: json['account_type'] as String? ?? json['accountType'] as String? ?? 'checking',
      currency: json['currency'] as String? ?? 'ILS',
      balance: (json['balance'] as num? ?? 0).toDouble(),
      ibanMasked: json['iban_masked'] as String? ?? json['ibanMasked'] as String?,
      budgetType: json['budget_type'] as String? ?? json['budgetType'] as String? ?? 'home',
    );
  }

  final String id;
  final String connectionId;
  final String providerCode;
  final String providerName;
  final String name;
  final String accountType;
  final String currency;
  final double balance;
  final String? ibanMasked;
  final String budgetType;
}

class BankProviderData {
  const BankProviderData({
    required this.code,
    required this.name,
    required this.nameEn,
  });

  factory BankProviderData.fromJson(Map<String, dynamic> json) {
    return BankProviderData(
      code: json['code'] as String,
      name: json['name'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? json['nameEn'] as String? ?? '',
    );
  }

  final String code;
  final String name;
  final String nameEn;
}

class BankProvidersData {
  const BankProvidersData({
    required this.mode,
    required this.providers,
    this.country = 'IL',
    this.currency = 'ILS',
  });

  factory BankProvidersData.fromJson(Map<String, dynamic> json) {
    return BankProvidersData(
      country: json['country'] as String? ?? 'IL',
      currency: json['currency'] as String? ?? 'ILS',
      mode: json['mode'] as String? ?? 'demo',
      providers: (json['providers'] as List<dynamic>? ?? [])
          .map((e) => BankProviderData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String country;
  final String currency;
  final String mode;
  final List<BankProviderData> providers;
}

class BankConnectionData {
  const BankConnectionData({
    required this.id,
    required this.providerCode,
    required this.providerName,
    required this.status,
    this.mode = 'demo',
    this.accountCount = 0,
  });

  factory BankConnectionData.fromJson(Map<String, dynamic> json) {
    return BankConnectionData(
      id: json['id'] as String,
      providerCode: json['provider_code'] as String? ?? json['providerCode'] as String? ?? '',
      providerName: json['provider_name'] as String? ?? json['providerName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      mode: json['mode'] as String? ?? 'demo',
      accountCount: json['account_count'] as int? ?? json['accountCount'] as int? ?? 0,
    );
  }

  final String id;
  final String providerCode;
  final String providerName;
  final String status;
  final String mode;
  final int accountCount;
}

class AssetReminderData {
  const AssetReminderData({
    required this.id,
    required this.assetType,
    required this.title,
    required this.expiryDate,
    required this.daysUntil,
    required this.status,
    this.documentLabel,
    this.notes,
    this.icon = 'document',
  });

  factory AssetReminderData.fromJson(Map<String, dynamic> json) {
    return AssetReminderData(
      id: json['id'] as String,
      assetType: json['asset_type'] as String? ?? json['assetType'] as String? ?? '',
      title: json['title'] as String,
      documentLabel:
          json['document_label'] as String? ?? json['documentLabel'] as String?,
      expiryDate: json['expiry_date'] as String? ?? json['expiryDate'] as String? ?? '',
      daysUntil: json['days_until'] as int? ?? json['daysUntil'] as int? ?? 0,
      status: json['status'] as String? ?? 'ok',
      icon: json['icon'] as String? ?? 'document',
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String assetType;
  final String title;
  final String? documentLabel;
  final String expiryDate;
  final int daysUntil;
  final String status;
  final String icon;
  final String? notes;
}

class InfoCategoryData {
  const InfoCategoryData({
    required this.id,
    required this.title,
    required this.icon,
    required this.items,
  });

  factory InfoCategoryData.fromJson(Map<String, dynamic> json) {
    return InfoCategoryData(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      items: (json['items'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  final String id;
  final String title;
  final String icon;
  final List<String> items;
}

class InfoHubData {
  const InfoHubData({
    required this.categories,
    this.reminders = const [],
    this.documents = const [],
    this.alertsCount = 0,
  });

  factory InfoHubData.fromJson(Map<String, dynamic> json) {
    return InfoHubData(
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => InfoCategoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
      reminders: (json['reminders'] as List<dynamic>? ?? [])
          .map((e) => AssetReminderData.fromJson(e as Map<String, dynamic>))
          .toList(),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((e) => InfoDocumentData.fromJson(e as Map<String, dynamic>))
          .toList(),
      alertsCount: json['alerts_count'] as int? ?? json['alertsCount'] as int? ?? 0,
    );
  }

  final List<InfoCategoryData> categories;
  final List<AssetReminderData> reminders;
  final List<InfoDocumentData> documents;
  final int alertsCount;

  List<AssetReminderData> get activeAlerts => reminders
      .where((r) => r.status == 'overdue' || r.status == 'urgent' || r.status == 'warning')
      .toList();
}

class InfoDocumentData {
  const InfoDocumentData({
    required this.id,
    required this.category,
    required this.categoryTitle,
    required this.title,
    this.summary,
    this.extractedText,
    this.expiryDate,
    this.confidence = 0,
    this.icon = 'document',
    this.createdAt,
  });

  factory InfoDocumentData.fromJson(Map<String, dynamic> json) {
    return InfoDocumentData(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'archive',
      categoryTitle:
          json['category_title'] as String? ?? json['categoryTitle'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String?,
      extractedText:
          json['extracted_text'] as String? ?? json['extractedText'] as String?,
      expiryDate: json['expiry_date'] as String? ?? json['expiryDate'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      icon: json['icon'] as String? ?? 'document',
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String?,
    );
  }

  final String id;
  final String category;
  final String categoryTitle;
  final String title;
  final String? summary;
  final String? extractedText;
  final String? expiryDate;
  final double confidence;
  final String icon;
  final String? createdAt;
}
