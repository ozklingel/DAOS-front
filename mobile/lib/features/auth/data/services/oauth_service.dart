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
  })  : _googleSignInOverride = googleSignIn,
        _appAuth = appAuth ?? const FlutterAppAuth();

  final GoogleSignIn? _googleSignInOverride;
  GoogleSignIn? _googleSignIn;
  final FlutterAppAuth _appAuth;

  /// Set via --dart-define only when non-empty. Empty define must not wipe the fallback.
  static const String _googleServerClientIdEnv =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  static const String _googleWebClientIdFallback =
      '812104653331-ur4g34kfo6seil4f6h06igl08ks9ecmt.apps.googleusercontent.com';

  static String get _googleServerClientId =>
      _googleServerClientIdEnv.isNotEmpty
          ? _googleServerClientIdEnv
          : _googleWebClientIdFallback;

  static const String _outlookClientId = String.fromEnvironment(
    'OUTLOOK_CLIENT_ID',
    defaultValue: 'YOUR_OUTLOOK_CLIENT_ID',
  );
  static const String _outlookRedirectUri = String.fromEnvironment(
    'OUTLOOK_REDIRECT_URI',
    defaultValue: 'com.taskmail://oauth/callback',
  );

  GoogleSignIn get _google {
    if (_googleSignInOverride != null) return _googleSignInOverride!;
    return _googleSignIn ??= GoogleSignIn(
      scopes: const [
        'email',
        'profile',
        'https://www.googleapis.com/auth/gmail.readonly',
      ],
      // Web MUST pass clientId — empty/null causes Google 401 invalid_client.
      clientId: kIsWeb ? _googleServerClientId : null,
      serverClientId: !kIsWeb ? _googleServerClientId : null,
      forceCodeForRefreshToken:
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
    );
  }

  Future<GoogleSignInCredentials> signInWithGoogle() async {
    try {
      if (kIsWeb && _googleServerClientId.startsWith('45773018634-')) {
        throw const AuthFailureException(
          'Wrong GOOGLE_SERVER_CLIENT_ID (old client). Stop the app and run: '
          'cd mobile; .\\scripts\\dev_web.ps1 — do not pass the old ID manually. '
          'See WEB_OAUTH_FIX.md.',
        );
      }

      if (_googleServerClientId.isEmpty) {
        throw const AuthFailureException(
          'GOOGLE_SERVER_CLIENT_ID is empty. Rebuild with a valid Web OAuth client ID.',
        );
      }

      final account = await _google.signIn();
      if (account == null) {
        throw const ValidationException('Google sign-in was cancelled.');
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if (idToken != null && idToken.isNotEmpty) {
        return GoogleSignInCredentials(
          idToken: idToken,
          serverAuthCode: account.serverAuthCode,
        );
      }

      // Web signIn() often returns access_token only (no id_token).
      if (kIsWeb && accessToken != null && accessToken.isNotEmpty) {
        return GoogleSignInCredentials(accessToken: accessToken);
      }

      if (_googleServerClientId.isEmpty) {
        throw const AuthFailureException(
          'Google ID token missing. Set GOOGLE_SERVER_CLIENT_ID to your Web OAuth '
          'client ID (same as GOOGLE_CLIENT_ID in backend/.env). Add it to '
          'mobile/android/local.properties as google.server.client.id, or pass '
          '--dart-define=GOOGLE_SERVER_CLIENT_ID=... when running flutter.',
        );
      }
      throw const AuthFailureException(
        'Failed to obtain Google credentials. Confirm GOOGLE_SERVER_CLIENT_ID matches '
        'your Web OAuth client in Google Cloud Console, then fully restart the app.',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('Google sign-in error: $e');
      final msg = e.toString();
      if (kIsWeb && (msg.contains('origin') || msg.contains('invalid_client') || msg.contains('popup') || msg.contains('OAuth client'))) {
        throw AuthFailureException(
          'Google Web OAuth failed (invalid_client / origin). '
          'In Google Cloud → APIs & Services → Credentials → Web client: '
          '1) Confirm client ID matches 812104653331-ur4g34kfo6seil4f6h06igl08ks9ecmt... '
          '2) Authorized JavaScript origins must include https://ozklingel.github.io '
          '(no path) and http://127.0.0.1:5173 for local. See WEB_OAUTH_FIX.md.',
        );
      }
      if (msg.contains('people.googleapis.com') || msg.contains('People API')) {
        throw const AuthFailureException(
          'Enable People API in Google Cloud (project daos-15254), wait 2 minutes, '
          'then try again. See WEB_OAUTH_FIX.md.',
        );
      }
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
    if (kIsWeb) {
      throw const AuthFailureException(
        'Outlook sign-in is not supported on web. Use Dev Login for local development.',
      );
    }

    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _outlookClientId,
          _outlookRedirectUri,
          discoveryUrl:
              'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration',
          scopes: const [
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
    await _google.signOut();
  }
}
