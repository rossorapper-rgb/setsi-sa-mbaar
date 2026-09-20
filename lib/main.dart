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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ------------------------------------------------------------
  // Restauration de la session
  // ------------------------------------------------------------

  final firebaseAuth = FirebaseAuth.instance;
  final localSession = LocalSessionService.instance;

  // Sur le Web, on demande à Firebase Auth de conserver
  // la session localement dans le navigateur.
  if (kIsWeb) {
    try {
      await firebaseAuth.setPersistence(Persistence.LOCAL);
    } catch (_) {
      // Si le navigateur refuse la persistance Firebase,
      // LocalSessionService pourra toujours servir de secours.
    }
  }

  // ------------------------------------------------------------
  // 1. Vérification de la session Firebase
  // ------------------------------------------------------------

  final firebaseUser = firebaseAuth.currentUser;

  if (firebaseUser != null) {
    try {
      final utilisateur = await FirebaseUtilisateurRepository()
          .getCurrentUtilisateur(firebaseUser.uid);

      if (utilisateur != null && utilisateur.actif) {
        CurrentUserService.instance.setCurrentUser(utilisateur);

        await CurrentBergerieConfig.instance.load(
          utilisateur.bergerieId,
        );

        // On actualise la copie locale avec les dernières
        // informations récupérées depuis Firebase.
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
      // ----------------------------------------------------------
      // Firebase est inaccessible.
      // On utilise la dernière session locale connue.
      // ----------------------------------------------------------

      final utilisateurLocal =
          await localSession.loadUtilisateur();

      if (utilisateurLocal != null && utilisateurLocal.actif) {
        CurrentUserService.instance.setCurrentUser(
          utilisateurLocal,
        );

        final configLocale =
            await localSession.loadBergerieConfig();

        if (configLocale != null) {
          CurrentBergerieConfig.instance.setConfig(
            configLocale,
          );
        } else {
          CurrentBergerieConfig.instance.clear();
        }
      } else {
        CurrentUserService.instance.clear();
        CurrentBergerieConfig.instance.clear();
      }
    }
  } else {
    // ------------------------------------------------------------
    // 2. Aucun utilisateur Firebase disponible.
    //
    // Cela peut arriver notamment lorsque le navigateur est
    // rouvert hors connexion.
    //
    // On tente alors directement la dernière session locale.
    // ------------------------------------------------------------

    final utilisateurLocal =
        await localSession.loadUtilisateur();

    if (utilisateurLocal != null && utilisateurLocal.actif) {
      CurrentUserService.instance.setCurrentUser(
        utilisateurLocal,
      );

      final configLocale =
          await localSession.loadBergerieConfig();

      if (configLocale != null) {
        CurrentBergerieConfig.instance.setConfig(
          configLocale,
        );
      } else {
        CurrentBergerieConfig.instance.clear();
      }
    } else {
      CurrentUserService.instance.clear();
      CurrentBergerieConfig.instance.clear();
    }
  }

  // ------------------------------------------------------------
  // Lancement de l'application
  // ------------------------------------------------------------

  runApp(
    const ProviderScope(
      child: SetsiApp(),
    ),
  );
}
