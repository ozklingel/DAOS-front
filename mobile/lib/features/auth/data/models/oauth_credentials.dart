class GoogleSignInCredentials {
  GoogleSignInCredentials({
    this.idToken,
    this.accessToken,
    this.serverAuthCode,
  }) {
    final hasIdToken = idToken != null && idToken!.isNotEmpty;
    final hasAccessToken = accessToken != null && accessToken!.isNotEmpty;
    assert(
      hasIdToken || hasAccessToken,
      'GoogleSignInCredentials requires idToken or accessToken',
    );
  }

  final String? idToken;
  final String? accessToken;
  final String? serverAuthCode;
}

class OutlookSignInCredentials {
  const OutlookSignInCredentials({
    required this.accessToken,
    this.refreshToken,
  });

  final String accessToken;
  final String? refreshToken;
}
