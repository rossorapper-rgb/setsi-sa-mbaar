import 'dart:async';

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

  await initializeDateFormatting('fr_FR');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseAuth = FirebaseAuth.instance;
  final localSession = LocalSessionService.instance;

  // Sur le Web, Firebase Auth conserve la session dans le navigateur.
  // Le délai évite qu'un navigateur bloque le démarrage de l'application.
  if (kIsWeb) {
    try {
      await firebaseAuth
          .setPersistence(Persistence.LOCAL)
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      // La session locale SET'S I reste le mécanisme de secours.
    }
  }

  try {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser != null) {
      try {
        final utilisateur = await FirebaseUtilisateurRepository()
            .getCurrentUtilisateur(firebaseUser.uid)
            .timeout(const Duration(seconds: 5));

        if (utilisateur != null && utilisateur.actif) {
          CurrentUserService.instance.setCurrentUser(utilisateur);

          await CurrentBergerieConfig.instance
              .load(utilisateur.bergerieId)
              .timeout(const Duration(seconds: 5));

          await localSession
              .saveUtilisateur(utilisateur)
              .timeout(const Duration(seconds: 3));

          await localSession
              .saveBergerieConfig(CurrentBergerieConfig.instance.config)
              .timeout(const Duration(seconds: 3));
        } else {
          await firebaseAuth.signOut();
          await localSession.clear();
          CurrentUserService.instance.clear();
          CurrentBergerieConfig.instance.clear();
        }
      } catch (_) {
        // Firebase indisponible ou trop lent : restauration locale.
        try {
          await _restoreLocalSession(localSession);
        } catch (_) {
          CurrentUserService.instance.clear();
          CurrentBergerieConfig.instance.clear();
        }
      }
    } else {
      // Cas important pour le Web hors connexion :
      // Firebase peut ne pas exposer immédiatement currentUser après
      // une réouverture du navigateur. On utilise alors la session locale.
      try {
        await _restoreLocalSession(localSession);
      } catch (_) {
        CurrentUserService.instance.clear();
        CurrentBergerieConfig.instance.clear();
      }
    }
  } catch (_) {
    // Une erreur de restauration ne doit jamais empêcher Flutter
    // d'afficher l'application et sa page de connexion.
    CurrentUserService.instance.clear();
    CurrentBergerieConfig.instance.clear();
  }

  runApp(
    const ProviderScope(
      child: SetsiApp(),
    ),
  );
}
