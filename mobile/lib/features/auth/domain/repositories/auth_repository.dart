import 'package:taskmail/features/auth/domain/entities/auth_tokens.dart';
import 'package:taskmail/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<bool> hasValidSession();
  Future<User> getCurrentUser();
  Future<AuthTokens> signInWithGoogle();
  Future<AuthTokens> signInWithOutlook();
  Future<AuthTokens> signInDev();
  Future<User> connectGmail();
  Future<User> connectOutlook();
  Future<User> disconnectGmail();
  Future<User> disconnectOutlook();
  Future<void> logout();
}
