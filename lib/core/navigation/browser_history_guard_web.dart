import 'dart:async';
import 'dart:html' as html;

import 'package:firebase_auth/firebase_auth.dart';

StreamSubscription<html.PopStateEvent>? _subscription;

void installBrowserHistoryGuard() {
  _subscription?.cancel();
  _subscription = html.window.onPopState.listen((_) {
    if (FirebaseAuth.instance.currentUser == null &&
        html.window.location.pathname != '/login') {
      html.window.location.replace('/login');
    }
  });
}
