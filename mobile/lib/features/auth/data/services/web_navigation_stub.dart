String webOrigin() => 'http://127.0.0.1:5173';

String webBaseHref() => '/';

void webRedirect(String url) {
  throw UnsupportedError('Web redirect is only available on web');
}

void webSessionSet(String key, String value) {}

String? webSessionGet(String key) => null;

void webSessionRemove(String key) {}
