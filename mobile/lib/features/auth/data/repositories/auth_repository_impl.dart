import 'package:taskmail/core/errors/app_exception.dart';
import 'package:taskmail/features/auth/data/models/auth_response_model.dart';
import 'package:taskmail/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:taskmail/features/auth/data/services/oauth_service.dart';
import 'package:taskmail/features/auth/domain/entities/auth_tokens.dart';
import 'package:taskmail/features/auth/domain/entities/user.dart';
import 'package:taskmail/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskmail/services/secure_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService storage,
    required OAuthService oauthService,
  })  : _remote = remoteDataSource,
        _storage = storage,
        _oauth = oauthService;

  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;
  final OAuthService _oauth;

  @override
  Future<bool> hasValidSession() async {
    if (!await _storage.hasToken()) return false;
    try {
      await _remote.getCurrentUser();
      return true;
    } on UnauthorizedException {
      await _storage.clearTokens();
      return false;
    } on AppException {
      return true;
    }
  }

  @override
  Future<User> getCurrentUser() async {
    final model = await _remote.getCurrentUser();
    return model.toEntity();
  }

  @override
  Future<AuthTokens> signInWithGoogle() async {
    final credentials = await _oauth.signInWithGoogle();
    final response = await _remote.signInWithGoogle(
      idToken: credentials.idToken,
      serverAuthCode: credentials.serverAuthCode,
    );
    await _persistTokens(response);
    return response.toEntity();
  }

  @override
  Future<AuthTokens> signInWithOutlook() async {
    final credentials = await _oauth.signInWithOutlook();
    final response = await _remote.signInWithOutlook(
      accessToken: credentials.accessToken,
      refreshToken: credentials.refreshToken,
    );
    await _persistTokens(response);
    return response.toEntity();
  }

  @override
  Future<AuthTokens> signInDev() async {
    final response = await _remote.signInDev();
    await _persistTokens(response);
    return response.toEntity();
  }

  @override
  Future<User> connectGmail() async {
    final credentials = await _oauth.signInWithGoogle();
    final model = await _remote.connectGoogle(
      idToken: credentials.idToken,
      serverAuthCode: credentials.serverAuthCode,
    );
    return model.toEntity();
  }

  @override
  Future<User> connectOutlook() async {
    final credentials = await _oauth.signInWithOutlook();
    final model = await _remote.connectOutlook(
      accessToken: credentials.accessToken,
      refreshToken: credentials.refreshToken,
    );
    return model.toEntity();
  }

  @override
  Future<User> disconnectGmail() async {
    final model = await _remote.disconnectGoogle();
    return model.toEntity();
  }

  @override
  Future<User> disconnectOutlook() async {
    final model = await _remote.disconnectOutlook();
    return model.toEntity();
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {}
    await _oauth.signOutGoogle();
    await _storage.clearTokens();
  }

  Future<void> _persistTokens(AuthResponseModel response) async {
    await _storage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userId: response.user?.id,
    );
  }
}
