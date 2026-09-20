import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Sur le Web, Firestore n'active pas la persistance locale par défaut.
  // On l'active avant toute lecture Firestore afin de pouvoir restaurer
  // les données déjà utilisées par l'application lorsque le réseau est
  // indisponible.
  if (kIsWeb) {
    try {
      await FirebaseFirestore.instance.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
    } catch (_) {
      // La persistance peut échouer si le navigateur ne la supporte pas
      // ou si une configuration de plusieurs onglets pose problème.
      // Firestore reste utilisable normalement dans ce cas.
    }
  }

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
      // Une erreur réseau ne doit pas transformer une session Firebase
      // encore valide en déconnexion applicative.
      //
      // Le profil local peut être restauré lors d'une prochaine
      // connexion réseau. On conserve donc ici l'état Firebase Auth.
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
