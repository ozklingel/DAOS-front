import 'package:daos/features/auth/domain/entities/auth_tokens.dart';
import 'package:daos/features/auth/domain/entities/user.dart';

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
  Future<User> connectWhatsApp(String phone);
  Future<User> disconnectWhatsApp();
  Future<User> connectSms(String phone);
  Future<User> disconnectSms();
  Future<void> logout();
}
