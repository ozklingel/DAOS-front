import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taskmail/features/auth/domain/entities/user.dart';

part 'auth_tokens.freezed.dart';

@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
    User? user,
  }) = _AuthTokens;
}
