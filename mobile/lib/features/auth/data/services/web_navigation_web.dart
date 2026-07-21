import 'dart:html' as html;

String webOrigin() {
  final location = html.window.location;
  final origin = location.origin;
  if (origin.isNotEmpty) return origin;
  return '${location.protocol}//${location.host}';
}

/// App mount path from the HTML base href, e.g. `/DAOS-front/` on GitHub Pages.
String webBaseHref() {
  final base = html.document.querySelector('base')?.getAttribute('href');
  if (base == null || base.isEmpty || base == './') return '/';
  return base.startsWith('/') ? base : '/$base';
}

void webRedirect(String url) {
  html.window.location.href = url;
}

void webSessionSet(String key, String value) {
  html.window.sessionStorage[key] = value;
}

String? webSessionGet(String key) => html.window.sessionStorage[key];

void webSessionRemove(String key) {
  html.window.sessionStorage.remove(key);
}
