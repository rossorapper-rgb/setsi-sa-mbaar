import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'core/config/current_bergerie_config.dart';
import 'core/session/current_user_service.dart';
import 'core/session/local_session_service.dart';
import 'features/utilisateurs/repository/firebase_utilisateur_repository.dart';

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

  try {
    await initializeDateFormatting('fr_FR');
  } catch (_) {}

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firebaseAuth = FirebaseAuth.instance;

    if (kIsWeb) {
      await firebaseAuth.setPersistence(Persistence.LOCAL);
    }

    // Firebase Auth reste la source de vérité lorsque la session est
    // disponible. Si le réseau ou Firebase pose problème, la session locale
    // déjà enregistrée prend le relais.
    final firebaseUser = firebaseAuth.currentUser ??
        await firebaseAuth
            .authStateChanges()
            .first
            .timeout(const Duration(seconds: 3));

    final localSession = LocalSessionService.instance;

    if (firebaseUser != null) {
      try {
        final utilisateur = await FirebaseUtilisateurRepository()
            .getCurrentUtilisateur(firebaseUser.uid);

        if (utilisateur != null && utilisateur.actif) {
          CurrentUserService.instance.setCurrentUser(utilisateur);

          await CurrentBergerieConfig.instance.load(
            utilisateur.bergerieId,
          );

          await localSession.saveUtilisateur(utilisateur);
          await localSession.saveBergerieConfig(
            CurrentBergerieConfig.instance.config,
          );
        } else {
          await firebaseAuth.signOut();
          CurrentUserService.instance.clear();
          CurrentBergerieConfig.instance.clear();
          await localSession.clear();
        }
      } catch (_) {
        await _restoreLocalSession(localSession);
      }
    } else {
      await _restoreLocalSession(localSession);
    }
  } catch (_) {
    // Si Firebase n'est pas accessible au démarrage, une session déjà
    // enregistrée localement peut tout de même permettre d'ouvrir
    // l'application hors connexion.
    try {
      await _restoreLocalSession(LocalSessionService.instance);
    } catch (_) {
      CurrentUserService.instance.clear();
      CurrentBergerieConfig.instance.clear();
    }
  }

  runApp(
    const ProviderScope(
      child: SetsiApp(),
    ),
  );
}
