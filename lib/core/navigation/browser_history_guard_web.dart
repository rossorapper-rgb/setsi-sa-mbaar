import 'dart:async';
import 'dart:html' as html;

import 'package:firebase_auth/firebase_auth.dart';

StreamSubscription<html.PopStateEvent>? _subscription;

void installBrowserHistoryGuard() {
  _subscription?.cancel();
  _subscription = html.window.onPopState.listen((_) {
    _redirectIfLoggedOut();
  });

  html.window.onPageShow.listen((_) {
    // Chrome can restore a previous Flutter Web document from bfcache
    // when the user presses Back/Forward. In that case popstate alone
    // is not enough to re-run the authentication guard.
    _redirectIfLoggedOut();
  });
}

void _redirectIfLoggedOut() {
  if (FirebaseAuth.instance.currentUser == null &&
      html.window.location.pathname != '/login') {
    html.window.location.replace('/login');
  }
}
