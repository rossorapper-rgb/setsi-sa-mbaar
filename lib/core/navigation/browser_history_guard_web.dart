import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:web/web.dart' as web;

JSFunction? _popStateListener;
JSFunction? _pageShowListener;

void installBrowserHistoryGuard() {
  if (_popStateListener != null) {
    web.window.removeEventListener('popstate', _popStateListener!);
  }
  if (_pageShowListener != null) {
    web.window.removeEventListener('pageshow', _pageShowListener!);
  }

  _popStateListener = ((web.Event _) {
    _redirectIfLoggedOut();
  }).toJS;

  _pageShowListener = ((web.Event _) {
    // Chrome can restore a previous Flutter Web document from bfcache
    // when the user presses Back/Forward. In that case popstate alone
    // is not enough to re-run the authentication guard.
    _redirectIfLoggedOut();
  }).toJS;

  web.window.addEventListener('popstate', _popStateListener!);
  web.window.addEventListener('pageshow', _pageShowListener!);
}

void _redirectIfLoggedOut() {
  if (FirebaseAuth.instance.currentUser == null &&
      web.window.location.pathname != '/login') {
    // When Back restores an authenticated route, bounce forward to the
    // current login entry instead of replacing the restored document.
    web.window.history.forward();
  }
}
