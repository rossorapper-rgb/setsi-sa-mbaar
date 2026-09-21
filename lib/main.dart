import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'core/config/current_bergerie_config.dart';
import 'core/session/current_user_service.dart';
import 'core/session/local_session_service.dart';

Future<void> _restoreLocalSession(
  LocalSessionService localSession,
) async {
  final utilisateurLocal = await localSession
      .loadUtilisateur()
      .timeout(const Duration(seconds: 3));

  if (utilisateurLocal != null && utilisateurLocal.actif) {
    CurrentUserService.instance.setCurrentUser(utilisateurLocal);

    final configLocale = await localSession
        .loadBergerieConfig()
        .timeout(const Duration(seconds: 3));

    if (configLocale != null) {
      CurrentBergerieConfig.instance.setConfig(configLocale);
    } else {
      CurrentBergerieConfig.instance.clear();
    }
  } else {
    CurrentUserService.instance.clear();
    CurrentBergerieConfig.instance.clear();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation minimale : Firebase reste disponible pour les écrans
  // qui en ont besoin, mais aucune lecture Auth/Firestore n'est effectuée
  // avant runApp(). Cela évite qu'un problème Firebase Web bloque tout
  // l'affichage de l'application hébergée.
  try {
    await initializeDateFormatting('fr_FR');
  } catch (_) {}

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // L'application peut tout de même démarrer avec la session locale.
  }

  final localSession = LocalSessionService.instance;

  try {
    await _restoreLocalSession(localSession);
  } catch (_) {
    CurrentUserService.instance.clear();
    CurrentBergerieConfig.instance.clear();
  }

  runApp(
    const ProviderScope(
      child: SetsiApp(),
    ),
  );
}
