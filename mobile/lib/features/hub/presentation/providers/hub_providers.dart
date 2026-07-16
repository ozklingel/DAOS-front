import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/network/api_client_provider.dart';
import 'package:taskmail/features/hub/data/datasources/hub_remote_datasource.dart';
import 'package:taskmail/features/hub/data/models/hub_models.dart';

final hubRemoteDataSourceProvider = Provider<HubRemoteDataSource>((ref) {
  return HubRemoteDataSource(ref.watch(apiClientProvider));
});

final profileProvider = FutureProvider<ProfileData>((ref) async {
  return ref.watch(hubRemoteDataSourceProvider).getProfile();
});

final calendarProvider =
    FutureProvider.family<CalendarData, String?>((ref, date) async {
  return ref.watch(hubRemoteDataSourceProvider).getCalendar(date: date);
});

final financeProvider = FutureProvider.family<FinanceData, String>((ref, type) async {
  return ref.watch(hubRemoteDataSourceProvider).getFinance(type: type);
});

final infoHubProvider = FutureProvider<InfoHubData>((ref) async {
  return ref.watch(hubRemoteDataSourceProvider).getInfoHub();
});
