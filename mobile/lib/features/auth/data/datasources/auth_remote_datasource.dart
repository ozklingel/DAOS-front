import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/errors/app_exception.dart';
import 'package:taskmail/core/network/api_client.dart';
import 'package:taskmail/features/auth/data/models/auth_response_model.dart';
import 'package:taskmail/features/auth/data/models/oauth_credentials.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthResponseModel> signInWithGoogle({
    String? idToken,
    String? accessToken,
    String? serverAuthCode,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authGoogle,
      data: {
        if (idToken != null) 'idToken': idToken,
        if (accessToken != null) 'accessToken': accessToken,
        if (serverAuthCode != null) 'serverAuthCode': serverAuthCode,
      },
      parser: (d) => d as Map<String, dynamic>,
    );
    return AuthResponseModel.fromJson(data);
  }

  Future<AuthResponseModel> signInWithOutlook({
    required String accessToken,
    String? refreshToken,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authOutlook,
      data: {
        'accessToken': accessToken,
        if (refreshToken != null) 'refreshToken': refreshToken,
      },
      parser: (d) => d as Map<String, dynamic>,
    );
    return AuthResponseModel.fromJson(data);
  }

  Future<UserModel> connectGoogle({
    String? idToken,
    String? accessToken,
    String? serverAuthCode,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authGoogleConnect,
      data: {
        if (idToken != null) 'idToken': idToken,
        if (accessToken != null) 'accessToken': accessToken,
        if (serverAuthCode != null) 'serverAuthCode': serverAuthCode,
      },
      parser: (d) => d as Map<String, dynamic>,
    );
    return UserModel.fromJson(data);
  }

  Future<UserModel> connectOutlook({
    required String accessToken,
    String? refreshToken,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authOutlookConnect,
      data: {
        'accessToken': accessToken,
        if (refreshToken != null) 'refreshToken': refreshToken,
      },
      parser: (d) => d as Map<String, dynamic>,
    );
    return UserModel.fromJson(data);
  }

  Future<String> getOutlookAuthorizeUrl({
    required String redirectUri,
    required String state,
    required String codeChallenge,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authOutlookAuthorizeUrl,
      data: {
        'redirectUri': redirectUri,
        'state': state,
        'codeChallenge': codeChallenge,
      },
      parser: (d) => d as Map<String, dynamic>,
    );
    return data['url'] as String;
  }

  Future<OutlookSignInCredentials> exchangeOutlookCode({
    required String code,
    required String redirectUri,
    required String codeVerifier,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authOutlookExchange,
      data: {
        'code': code,
        'redirectUri': redirectUri,
        'codeVerifier': codeVerifier,
      },
      parser: (d) => d as Map<String, dynamic>,
    );
    final access = data['access_token'] as String? ?? data['accessToken'] as String?;
    if (access == null || access.isEmpty) {
      throw const AuthFailureException('Outlook token exchange failed.');
    }
    return OutlookSignInCredentials(
      accessToken: access,
      refreshToken: data['refresh_token'] as String? ?? data['refreshToken'] as String?,
    );
  }

  Future<UserModel> disconnectGoogle() async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authGoogleDisconnect,
      parser: (d) => d as Map<String, dynamic>,
    );
    return UserModel.fromJson(data);
  }

  Future<UserModel> disconnectOutlook() async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authOutlookDisconnect,
      parser: (d) => d as Map<String, dynamic>,
    );
    return UserModel.fromJson(data);
  }

  Future<UserModel> linkWhatsApp(String phone) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authWhatsAppLink,
      data: {'phone': phone},
      parser: (d) => d as Map<String, dynamic>,
    );
    return UserModel.fromJson(data);
  }

  Future<UserModel> disconnectWhatsApp() async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authWhatsAppDisconnect,
      parser: (d) => d as Map<String, dynamic>,
    );
    return UserModel.fromJson(data);
  }

  Future<UserModel> getCurrentUser() async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.authMe,
      parser: (d) => d as Map<String, dynamic>,
    );
    return UserModel.fromJson(data);
  }

  Future<void> logout() async {
    await _client.post<void>(ApiConstants.authLogout);
  }

  Future<AuthResponseModel> signInDev() async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authDev,
      parser: (d) => d as Map<String, dynamic>,
    );
    return AuthResponseModel.fromJson(data);
  }
}
