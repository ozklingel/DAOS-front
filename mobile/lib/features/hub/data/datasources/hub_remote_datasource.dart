import 'package:dio/dio.dart';
import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/network/api_client.dart';
import 'package:taskmail/features/hub/data/models/hub_models.dart';
import 'package:taskmail/features/info/data/services/document_capture_service.dart';

class HubRemoteDataSource {
  HubRemoteDataSource(this._client);

  final ApiClient _client;

  Future<ProfileData> getProfile() async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.profile,
      parser: (d) => d as Map<String, dynamic>,
    );
    return ProfileData.fromJson(data);
  }

  Future<CalendarData> getCalendar({String? date}) async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.calendar,
      queryParameters: date != null ? {'date': date} : null,
      parser: (d) => d as Map<String, dynamic>,
    );
    return CalendarData.fromJson(data);
  }

  Future<FinanceData> getFinance({String type = 'home'}) async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.finance,
      queryParameters: {'type': type},
      parser: (d) => d as Map<String, dynamic>,
    );
    return FinanceData.fromJson(data);
  }

  Future<FinanceTransactionData> createFinanceTransaction({
    required String budgetType,
    required String title,
    required double amount,
    required String txType,
    String category = 'general',
    String icon = 'payment',
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.financeTransactions,
      data: {
        'budget_type': budgetType,
        'title': title,
        'amount': amount,
        'tx_type': txType,
        'category': category,
        'icon': icon,
      },
      parser: (d) => d as Map<String, dynamic>,
    );
    return FinanceTransactionData.fromJson(data);
  }

  Future<BankProvidersData> getBankProviders() async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.bankProviders,
      parser: (d) => d as Map<String, dynamic>,
    );
    return BankProvidersData.fromJson(data);
  }

  Future<Map<String, dynamic>> connectBank({
    required String providerCode,
    String budgetType = 'home',
  }) async {
    return _client.post<Map<String, dynamic>>(
      ApiConstants.bankConnect,
      data: {
        'provider_code': providerCode,
        'budget_type': budgetType,
      },
      parser: (d) => d as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> syncBankConnection(String connectionId) async {
    return _client.post<Map<String, dynamic>>(
      '${ApiConstants.bankConnections}/$connectionId/sync',
      parser: (d) => d as Map<String, dynamic>,
    );
  }

  Future<void> disconnectBank(String connectionId) async {
    await _client.delete('${ApiConstants.bankConnections}/$connectionId');
  }

  Future<InfoHubData> getInfoHub() async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.infoHub,
      parser: (d) => d as Map<String, dynamic>,
    );
    return InfoHubData.fromJson(data);
  }

  Future<InfoDocumentData> uploadInfoDocument(CapturedImage image) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        image.bytes,
        filename: image.filename,
      ),
    });
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.infoDocuments,
      data: form,
      options: Options(
        sendTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
      ),
      parser: (d) => d as Map<String, dynamic>,
    );
    final document = data['document'] as Map<String, dynamic>? ?? data;
    return InfoDocumentData.fromJson(document);
  }

  Future<void> deleteInfoDocument(String id) async {
    await _client.delete('${ApiConstants.infoDocuments}/$id');
  }

  Future<AssetReminderData> updateAsset({
    required String id,
    String? title,
    String? expiryDate,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (expiryDate != null) body['expiry_date'] = expiryDate;
    if (notes != null) body['notes'] = notes;

    final data = await _client.patch<Map<String, dynamic>>(
      '${ApiConstants.assets}/$id',
      data: body,
      parser: (d) => d as Map<String, dynamic>,
    );
    return AssetReminderData.fromJson(data);
  }
}
