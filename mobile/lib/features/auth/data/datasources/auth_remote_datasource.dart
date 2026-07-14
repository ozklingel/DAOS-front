import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/network/api_client.dart';
import 'package:taskmail/features/auth/data/models/auth_response_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthResponseModel> signInWithGoogle({
    required String idToken,
    String? serverAuthCode,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authGoogle,
      data: {
        'idToken': idToken,
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
    required String idToken,
    String? serverAuthCode,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.authGoogleConnect,
      data: {
        'idToken': idToken,
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
