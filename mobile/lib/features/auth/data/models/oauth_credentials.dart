class GoogleSignInCredentials {
  const GoogleSignInCredentials({
    required this.idToken,
    this.serverAuthCode,
  });

  final String idToken;
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
