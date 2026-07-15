import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmail/core/errors/app_exception.dart';
import 'package:taskmail/features/auth/data/models/oauth_credentials.dart';

class OAuthService {
  OAuthService({
    GoogleSignIn? googleSignIn,
    FlutterAppAuth? appAuth,
  })  : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: [
                'email',
                'profile',
                'https://www.googleapis.com/auth/gmail.readonly',
              ],
              serverClientId: _googleServerClientId.isEmpty
                  ? null
                  : _googleServerClientId,
              forceCodeForRefreshToken: Platform.isAndroid,
            ),
        _appAuth = appAuth ?? const FlutterAppAuth();

  final GoogleSignIn _googleSignIn;
  final FlutterAppAuth _appAuth;

  static const String _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static const String _outlookClientId = String.fromEnvironment(
    'OUTLOOK_CLIENT_ID',
    defaultValue: 'YOUR_OUTLOOK_CLIENT_ID',
  );
  static const String _outlookRedirectUri = String.fromEnvironment(
    'OUTLOOK_REDIRECT_URI',
    defaultValue: 'com.taskmail://oauth/callback',
  );

  Future<GoogleSignInCredentials> signInWithGoogle() async {
    try {
      if (_googleServerClientId.isEmpty) {
        debugPrint(
          'GOOGLE_SERVER_CLIENT_ID is not set. Gmail sync requires the Web OAuth client ID.',
        );
      }

      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const ValidationException('Google sign-in was cancelled.');
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        if (_googleServerClientId.isEmpty) {
          throw const AuthFailureException(
            'Google ID token missing. Set GOOGLE_SERVER_CLIENT_ID to your Web OAuth '
            'client ID (same as GOOGLE_CLIENT_ID in backend/.env). Add it to '
            'mobile/android/local.properties as google.server.client.id, or pass '
            '--dart-define=GOOGLE_SERVER_CLIENT_ID=... when running flutter.',
          );
        }
        throw const AuthFailureException(
          'Failed to obtain Google ID token. Confirm GOOGLE_SERVER_CLIENT_ID matches '
          'your Web OAuth client in Google Cloud Console, then fully restart the app.',
        );
      }

      return GoogleSignInCredentials(
        idToken: idToken,
        serverAuthCode: account.serverAuthCode,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('Google sign-in error: $e');
      if (e is PlatformException && e.code == 'sign_in_failed') {
        final message = e.message ?? '';
        if (message.contains('ApiException: 10')) {
          throw const AuthFailureException(
            'Google Sign-In is not configured. Add SHA-1 fingerprint and OAuth '
            'client IDs in Google Cloud Console, or use Dev Login in debug mode.',
          );
        }
      }
      throw const AuthFailureException('Google sign-in failed.');
    }
  }

  Future<OutlookSignInCredentials> signInWithOutlook() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _outlookClientId,
          _outlookRedirectUri,
          discoveryUrl:
              'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration',
          scopes: [
            'openid',
            'profile',
            'email',
            'offline_access',
            'Mail.Read',
          ],
        ),
      );

      final accessToken = result.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw const AuthFailureException('Failed to obtain Outlook access token.');
      }

      return OutlookSignInCredentials(
        accessToken: accessToken,
        refreshToken: result.refreshToken,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('Outlook sign-in error: $e');
      throw const AuthFailureException('Outlook sign-in failed.');
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }
}
