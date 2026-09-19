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
      firebaseAuth.currentUser ??
          await firebaseAuth.authStateChanges().first;

  if (firebaseUser != null) {
    try {
      final utilisateur = await FirebaseUtilisateurRepository()
          .getCurrentUtilisateur(firebaseUser.uid);

      if (utilisateur != null && utilisateur.actif) {
        CurrentUserService.instance.setCurrentUser(utilisateur);

        // --------------------------------------------------------
        // Chargement de la configuration de la bergerie
        // --------------------------------------------------------
        //
        // Le bergerieId du compte connecté devient la clé de
        // recherche de la configuration personnalisée dans
        // Firestore.
        // --------------------------------------------------------
        await CurrentBergerieConfig.instance.load(
          utilisateur.bergerieId,
        );
      } else if (utilisateur == null || !utilisateur.actif) {
        await firebaseAuth.signOut();
        CurrentUserService.instance.clear();
        CurrentBergerieConfig.instance.clear();
      }
    } catch (_) {
      // En cas d'erreur de récupération du profil ou de la
      // configuration, l'application démarre avec la configuration
      // par défaut et le routeur pourra rediriger vers /login.
      CurrentUserService.instance.clear();
      CurrentBergerieConfig.instance.clear();
    }
  } else {
    CurrentBergerieConfig.instance.clear();
  }

  runApp(
    const ProviderScope(
      child: SetsiApp(),
    ),
  );
}
