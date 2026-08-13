import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'core/session/current_user_service.dart';
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
  //
  // Firebase peut conserver la session même lorsqu'une nouvelle
  // instance de l'application est ouverte.
  //
  // Nous devons également recharger le profil SET'SI correspondant
  // afin que CurrentUserService connaisse le rôle de l'utilisateur.
  // ------------------------------------------------------------

  final firebaseAuth = FirebaseAuth.instance;

  final firebaseUser =
      firebaseAuth.currentUser ??
          await firebaseAuth.authStateChanges().first;

  if (firebaseUser != null) {
    try {
      final utilisateur =
      await FirebaseUtilisateurRepository()
          .getCurrentUtilisateur(firebaseUser.uid);

      if (utilisateur != null && utilisateur.actif) {
        CurrentUserService.instance.setCurrentUser(
          utilisateur,
        );
      } else if (utilisateur == null || !utilisateur.actif) {
        await firebaseAuth.signOut();
        CurrentUserService.instance.clear();
      }
    } catch (_) {
      // En cas d'erreur de récupération du profil,
      // on ne bloque pas le démarrage de l'application.
      //
      // Le routeur pourra alors rediriger vers /login.
      CurrentUserService.instance.clear();
    }
  }

  runApp(
    const ProviderScope(
      child: SetsiApp(),
    ),
  );
}