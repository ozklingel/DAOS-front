import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taskmail/features/auth/domain/entities/auth_tokens.dart';
import 'package:taskmail/features/auth/domain/entities/user.dart';

part 'auth_response_model.freezed.dart';

@freezed
abstract class AuthResponseModel with _$AuthResponseModel {
  const AuthResponseModel._();

  const factory AuthResponseModel({
    required String accessToken,
    required String refreshToken,
    UserModel? user,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken:
          json['access_token'] as String? ?? json['accessToken'] as String,
      refreshToken:
          json['refresh_token'] as String? ?? json['refreshToken'] as String,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  AuthTokens toEntity() => AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user?.toEntity(),
      );
}

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    String? name,
    String? avatarUrl,
    @Default(false) bool gmailConnected,
    @Default(false) bool outlookConnected,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarUrl:
          json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      gmailConnected:
          json['gmail_connected'] as bool? ?? json['gmailConnected'] as bool? ?? false,
      outlookConnected: json['outlook_connected'] as bool? ??
          json['outlookConnected'] as bool? ??
          false,
    );
  }

  User toEntity() => User(
        id: id,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        gmailConnected: gmailConnected,
        outlookConnected: outlookConnected,
      );
}
