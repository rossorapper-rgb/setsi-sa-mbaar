import 'dart:async';
import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:web/web.dart' as web;

StreamSubscription<web.PopStateEvent>? _subscription;

void installBrowserHistoryGuard() {
  _subscription?.cancel();
  _subscription = web.window.onpopstate.listen((_) {
    _redirectIfLoggedOut();
  });

  web.window.onpageshow.listen((_) {
    // Chrome can restore a previous Flutter Web document from bfcache
    // when the user presses Back/Forward. In that case popstate alone
    // is not enough to re-run the authentication guard.
    _redirectIfLoggedOut();
  });
}

void _redirectIfLoggedOut() {
  if (FirebaseAuth.instance.currentUser == null &&
      web.window.location.pathname != '/login') {
    // When Back restores an authenticated route, bounce forward to the
    // current login entry instead of replacing the restored document.
    web.window.history.forward();
  }
}
