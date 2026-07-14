import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/network/api_client_provider.dart';
import 'package:taskmail/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:taskmail/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:taskmail/features/auth/data/services/oauth_service.dart';
import 'package:taskmail/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskmail/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:taskmail/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:taskmail/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:taskmail/features/daily_brief/data/datasources/daily_brief_remote_datasource.dart';
import 'package:taskmail/features/daily_brief/data/repositories/daily_brief_repository_impl.dart';
import 'package:taskmail/features/daily_brief/domain/repositories/daily_brief_repository.dart';
import 'package:taskmail/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:taskmail/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:taskmail/features/settings/domain/repositories/settings_repository.dart';
import 'package:taskmail/features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'package:taskmail/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:taskmail/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:taskmail/services/secure_storage_service.dart';

final oauthServiceProvider = Provider<OAuthService>((ref) => OAuthService());

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    storage: ref.watch(secureStorageServiceProvider),
    oauthService: ref.watch(oauthServiceProvider),
  );
});

final tasksRemoteDataSourceProvider = Provider<TasksRemoteDataSource>((ref) {
  return TasksRemoteDataSource(ref.watch(apiClientProvider));
});

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepositoryImpl(ref.watch(tasksRemoteDataSourceProvider));
});

final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(ref.watch(apiClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

final dailyBriefRemoteDataSourceProvider =
    Provider<DailyBriefRemoteDataSource>((ref) {
  return DailyBriefRemoteDataSource(ref.watch(apiClientProvider));
});

final dailyBriefRepositoryProvider = Provider<DailyBriefRepository>((ref) {
  return DailyBriefRepositoryImpl(ref.watch(dailyBriefRemoteDataSourceProvider));
});

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  return SettingsRemoteDataSource(ref.watch(apiClientProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(settingsRemoteDataSourceProvider));
});
