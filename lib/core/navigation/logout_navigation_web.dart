import 'package:web/web.dart' as web;

void navigateToLoginAfterLogout() {
  final history = web.window.history;
  history.replaceState(null, '', '/login');
  history.pushState(null, '', '/login');
}
