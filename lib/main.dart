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
  // Restauration de la session Firebase
  // ------------------------------------------------------------

  final firebaseAuth = FirebaseAuth.instance;

  // Sur le Web, on force explicitement la persistance locale de Firebase Auth.
  // La session reste ainsi disponible après fermeture puis réouverture du navigateur.
  if (kIsWeb) {
    await firebaseAuth.setPersistence(Persistence.LOCAL);
  }

  final firebaseUser =
      await firebaseAuth.authStateChanges().first;

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
      // Firestore peut être momentanément inaccessible hors connexion.
      // Dans ce cas, on restaure le profil et le branding déjà enregistrés
      // localement lors d'une précédente connexion réussie.
      final utilisateurLocal = await localSession.loadUtilisateur();

      if (utilisateurLocal != null && utilisateurLocal.actif) {
        CurrentUserService.instance.setCurrentUser(utilisateurLocal);

        final configLocale = await localSession.loadBergerieConfig();
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
  } else {
    // Firebase Auth peut ne pas restituer immédiatement l'utilisateur
    // lorsque le navigateur est hors connexion. La session applicative
    // locale devient alors notre secours pour une session déjà ouverte.
    final utilisateurLocal = await localSession.loadUtilisateur();

    if (utilisateurLocal != null && utilisateurLocal.actif) {
      CurrentUserService.instance.setCurrentUser(utilisateurLocal);

      final configLocale = await localSession.loadBergerieConfig();
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

  runApp(
    const ProviderScope(
      child: SetsiApp(),
    ),
  );
}
