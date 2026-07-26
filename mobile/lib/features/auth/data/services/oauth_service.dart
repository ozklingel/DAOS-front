import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmail/core/errors/app_exception.dart';
import 'package:taskmail/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:taskmail/features/auth/data/models/oauth_credentials.dart';
import 'package:taskmail/features/auth/data/services/web_navigation.dart';

class OAuthService {
  OAuthService({
    GoogleSignIn? googleSignIn,
    FlutterAppAuth? appAuth,
    AuthRemoteDataSource? authRemote,
  })  : _googleSignInOverride = googleSignIn,
        _appAuth = appAuth ?? const FlutterAppAuth(),
        _authRemoteOverride = authRemote;

  final GoogleSignIn? _googleSignInOverride;
  GoogleSignIn? _googleSignIn;
  final FlutterAppAuth _appAuth;
  final AuthRemoteDataSource? _authRemoteOverride;
  AuthRemoteDataSource? _authRemote;

  /// Login only — avoids Google 403 when Gmail scope is unverified.
  static const List<String> _loginScopes = [
    'email',
    'profile',
  ];

  /// Restricted scope — request only when user connects Gmail in Settings.
  static const String _gmailReadonlyScope =
      'https://www.googleapis.com/auth/gmail.readonly';

  /// Set via --dart-define only when non-empty. Empty define must not wipe the fallback.
  static const String _googleServerClientIdEnv =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  static const String _googleWebClientIdFallback =
      '812104653331-ur4g34kfo6seil4f6h06igl08ks9ecmt.apps.googleusercontent.com';

  static String get _googleServerClientId =>
      _googleServerClientIdEnv.isNotEmpty
          ? _googleServerClientIdEnv
          : _googleWebClientIdFallback;

  static const String _outlookClientIdEnv = String.fromEnvironment('OUTLOOK_CLIENT_ID');
  static const String _outlookRedirectUri = String.fromEnvironment(
    'OUTLOOK_REDIRECT_URI',
    defaultValue: 'com.taskmail://oauth/callback',
  );

  static String get outlookClientId => _outlookClientIdEnv;

  /// Includes GitHub Pages base path (e.g. /DAOS-front/), not just origin.
  static String webOutlookRedirectUri() {
    final origin = webOrigin();
    final baseHref = webBaseHref(); // e.g. "/DAOS-front/" or "/"
    final base = baseHref.endsWith('/')
        ? baseHref.substring(0, baseHref.length - 1)
        : baseHref;
    if (base.isEmpty) return '$origin/oauth/outlook';
    return '$origin$base/oauth/outlook';
  }

  void bindAuthRemote(AuthRemoteDataSource remote) {
    _authRemote = remote;
  }

  AuthRemoteDataSource get _remote {
    final remote = _authRemoteOverride ?? _authRemote;
    if (remote == null) {
      throw const AuthFailureException('Auth remote is not configured for Outlook web OAuth.');
    }
    return remote;
  }

  GoogleSignIn _buildGoogleSignIn({
    required List<String> scopes,
    bool forceServerAuthCode = false,
  }) {
    return GoogleSignIn(
      scopes: scopes,
      // Web MUST pass clientId — empty/null causes Google 401 invalid_client.
      clientId: kIsWeb ? _googleServerClientId : null,
      serverClientId: !kIsWeb ? _googleServerClientId : null,
      forceCodeForRefreshToken: forceServerAuthCode ||
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.android),
    );
  }

  GoogleSignIn get _google {
    if (_googleSignInOverride != null) return _googleSignInOverride;
    return _googleSignIn ??= _buildGoogleSignIn(scopes: _loginScopes);
  }

  void _assertGoogleClientConfigured() {
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
  }

  Future<GoogleSignInCredentials> _credentialsFrom(
    GoogleSignInAccount account,
  ) async {
    final auth = await account.authentication;
    final idToken = auth.idToken;
    final accessToken = auth.accessToken;

    if (idToken != null && idToken.isNotEmpty) {
      return GoogleSignInCredentials(
        idToken: idToken,
        accessToken: accessToken,
        serverAuthCode: account.serverAuthCode,
      );
    }

    // Web signIn() often returns access_token only (no id_token).
    if (kIsWeb && accessToken != null && accessToken.isNotEmpty) {
      return GoogleSignInCredentials(
        accessToken: accessToken,
        serverAuthCode: account.serverAuthCode,
      );
    }

    throw const AuthFailureException(
      'Failed to obtain Google credentials. Confirm GOOGLE_SERVER_CLIENT_ID matches '
      'your Web OAuth client in Google Cloud Console, then fully restart the app.',
    );
  }

  Future<GoogleSignInCredentials> signInWithGoogle() async {
    try {
      _assertGoogleClientConfigured();

      final account = await _google.signIn();
      if (account == null) {
        throw const ValidationException('Google sign-in was cancelled.');
      }
      return _credentialsFrom(account);
    } catch (e) {
      throw _mapGoogleError(e);
    }
  }

  /// Second-step consent for inbox sync (Settings → Connect Gmail).
  Future<GoogleSignInCredentials> authorizeGmailAccess() async {
    try {
      _assertGoogleClientConfigured();

      // Prefer incremental consent on the existing login session.
      var account = _google.currentUser;
      account ??= await _google.signInSilently();
      account ??= await _google.signIn();
      if (account == null) {
        throw const ValidationException('Google sign-in was cancelled.');
      }

      final granted = await _google.requestScopes(const [_gmailReadonlyScope]);
      if (granted) {
        return _credentialsFrom(account);
      }

      // Fallback: dedicated client that includes Gmail from the start
      // (needed on some web / platform combinations).
      final gmailClient = _googleSignInOverride ??
          _buildGoogleSignIn(
            scopes: const [..._loginScopes, _gmailReadonlyScope],
            forceServerAuthCode: true,
          );
      final gmailAccount = await gmailClient.signIn();
      if (gmailAccount == null) {
        throw const ValidationException('Gmail authorization was cancelled.');
      }
      return _credentialsFrom(gmailAccount);
    } catch (e) {
      if (e is AppException) rethrow;
      final mapped = _mapGoogleError(e);
      if (mapped.message == 'Google sign-in failed.') {
        throw const AuthFailureException(
          'Gmail access was denied or blocked. If Google shows 403, the app still '
          'needs Gmail scope verification — login works without it.',
        );
      }
      throw mapped;
    }
  }

  AppException _mapGoogleError(Object e) {
    if (e is AppException) return e;
    debugPrint('Google sign-in error: $e');
    final msg = e.toString();
    if (kIsWeb &&
        (msg.contains('origin') ||
            msg.contains('invalid_client') ||
            msg.contains('popup') ||
            msg.contains('OAuth client'))) {
      return AuthFailureException(
        'Google Web OAuth failed (invalid_client / origin). '
        'In Google Cloud → APIs & Services → Credentials → Web client: '
        '1) Confirm client ID matches 812104653331-ur4g34kfo6seil4f6h06igl08ks9ecmt... '
        '2) Authorized JavaScript origins must include https://ozklingel.github.io '
        '(no path) and http://127.0.0.1:5173 for local. See WEB_OAUTH_FIX.md.',
      );
    }
    if (msg.contains('people.googleapis.com') || msg.contains('People API')) {
      return const AuthFailureException(
        'Enable People API in Google Cloud (project daos-15254), wait 2 minutes, '
        'then try again. See WEB_OAUTH_FIX.md.',
      );
    }
    if (e is PlatformException && e.code == 'sign_in_failed') {
      final message = e.message ?? '';
      if (message.contains('ApiException: 10')) {
        return const AuthFailureException(
          'Google Sign-In is not configured. Add SHA-1 fingerprint and OAuth '
          'client IDs in Google Cloud Console, or use Dev Login in debug mode.',
        );
      }
    }
    return const AuthFailureException('Google sign-in failed.');
  }

  Future<OutlookSignInCredentials> signInWithOutlook({String intent = 'login'}) async {
    if (kIsWeb) {
      return _signInWithOutlookWeb(intent: intent);
    }

    if (outlookClientId.isEmpty || outlookClientId == 'YOUR_OUTLOOK_CLIENT_ID') {
      throw const AuthFailureException(
        'OUTLOOK_CLIENT_ID is missing. Set MICROSOFT_CLIENT_ID in backend/.env '
        'and pass --dart-define=OUTLOOK_CLIENT_ID=... (see OAUTH_SETUP.md).',
      );
    }

    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          outlookClientId,
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

  Future<OutlookSignInCredentials> _signInWithOutlookWeb({required String intent}) async {
    final verifier = _pkceVerifier();
    final challenge = _pkceChallenge(verifier);
    final state = _randomUrlSafe(24);
    final redirectUri = webOutlookRedirectUri();

    webSessionSet('outlook_code_verifier', verifier);
    webSessionSet('outlook_oauth_state', state);
    webSessionSet('outlook_oauth_intent', intent);
    webSessionSet('outlook_redirect_uri', redirectUri);

    final url = await _remote.getOutlookAuthorizeUrl(
      redirectUri: redirectUri,
      state: state,
      codeChallenge: challenge,
    );
    webRedirect(url);
    // Navigation leaves this page; caller never continues.
    throw const AuthFailureException('Redirecting to Microsoft login…');
  }

  Future<OutlookSignInCredentials> completeOutlookWebCallback({
    required String code,
    required String state,
  }) async {
    final expectedState = webSessionGet('outlook_oauth_state');
    final verifier = webSessionGet('outlook_code_verifier');
    final redirectUri = webSessionGet('outlook_redirect_uri') ?? webOutlookRedirectUri();

    if (expectedState == null || expectedState != state) {
      throw const AuthFailureException('Outlook login state mismatch. Try again.');
    }
    if (verifier == null || verifier.isEmpty) {
      throw const AuthFailureException('Outlook login session expired. Try again.');
    }

    final credentials = await _remote.exchangeOutlookCode(
      code: code,
      redirectUri: redirectUri,
      codeVerifier: verifier,
    );

    webSessionRemove('outlook_code_verifier');
    webSessionRemove('outlook_oauth_state');
    webSessionRemove('outlook_redirect_uri');
    return credentials;
  }

  String? consumeOutlookIntent() {
    final intent = webSessionGet('outlook_oauth_intent');
    webSessionRemove('outlook_oauth_intent');
    return intent;
  }

  static String _pkceVerifier() => _randomUrlSafe(64);

  static String _pkceChallenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  static String _randomUrlSafe(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  Future<void> signOutGoogle() async {
    await _google.signOut();
  }
}
