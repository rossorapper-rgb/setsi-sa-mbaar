import 'dart:html' as html;

void navigateToLoginAfterLogout() {
  final history = html.window.history;
  history.replaceState(null, '', '/login');
  history.pushState(null, '', '/login');
}
