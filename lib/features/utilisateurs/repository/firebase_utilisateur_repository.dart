import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/utilisateur_model.dart';

class FirebaseUtilisateurRepository {
  FirebaseUtilisateurRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'users';

  /// ===========================
  /// Ajouter un utilisateur
  /// ===========================
  Future<void> addUtilisateur(
      UtilisateurModel utilisateur,
      ) async {
    await _firestore
        .collection(_collection)
        .doc(utilisateur.id)
        .set(utilisateur.toMap());
  }

  /// ===========================
  /// Créer un utilisateur complet
  /// Firebase Authentication
  /// + Firestore
  /// ===========================
  Future<void> createUtilisateurAvecCompte(
      UtilisateurModel utilisateur,
      String motDePasse,
      ) async {
    if (motDePasse.trim().length < 6) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: 'Le mot de passe doit contenir au moins 6 caractères.',
      );
    }

    FirebaseApp? secondaryApp;
    UserCredential? credential;
    bool profilCree = false;

    try {
      final telephoneExisteDeja =
      await this.telephoneExiste(utilisateur.telephone);

      if (telephoneExisteDeja) {
        throw FirebaseAuthException(
          code: 'telephone-already-in-use',
          message: 'Ce numéro de téléphone est déjà utilisé.',
        );
      }

      final nomApplication =
          'setsi-user-${DateTime.now().microsecondsSinceEpoch}';

      secondaryApp = await Firebase.initializeApp(
        name: nomApplication,
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(
        app: secondaryApp,
      );

      credential =
      await secondaryAuth.createUserWithEmailAndPassword(
        email: utilisateur.emailTechnique,
        password: motDePasse.trim(),
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Impossible de récupérer le compte Firebase créé.',
        );
      }

      final utilisateurAvecUid = utilisateur.copyWith(
        id: firebaseUser.uid,
      );

      await addUtilisateur(utilisateurAvecUid);

      profilCree = true;
    } catch (e) {
      if (!profilCree) {
        try {
          await credential?.user?.delete();
        } catch (_) {
          // Suppression de sécurité best-effort.
        }
      }

      rethrow;
    } finally {
      try {
        await secondaryApp?.delete();
      } catch (_) {
        // Nettoyage best-effort.
      }
    }
  }

  /// ===========================
  /// Modifier un utilisateur
  /// ===========================
  Future<void> updateUtilisateur(
      UtilisateurModel utilisateur,
      ) async {
    await _firestore
        .collection(_collection)
        .doc(utilisateur.id)
        .update(utilisateur.toMap());
  }

  /// ===========================
  /// Désactiver un utilisateur
  /// ===========================
  Future<void> deleteUtilisateur(
      String id,
      ) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .update({
      'actif': false,
    });
  }

  /// ===========================
  /// Réactiver un utilisateur
  /// ===========================
  Future<void> reactiverUtilisateur(
      String id,
      ) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .update({
      'actif': true,
    });
  }

  /// ===========================
  /// Charger un utilisateur
  /// ===========================
  Future<UtilisateurModel?> getUtilisateurById(
      String id,
      ) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(id)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UtilisateurModel.fromMap(
      doc.data()!,
      doc.id,
    );
  }

  /// ===========================
  /// Rechercher par téléphone
  /// ===========================
  Future<UtilisateurModel?> getUtilisateurByTelephone(
      String telephone,
      ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
      'telephone',
      isEqualTo: telephone,
    )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final doc = snapshot.docs.first;

    return UtilisateurModel.fromMap(
      doc.data(),
      doc.id,
    );
  }

  /// ===========================
  /// Tous les utilisateurs actifs
  /// ===========================
  Future<List<UtilisateurModel>> getUtilisateurs() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
      'actif',
      isEqualTo: true,
    )
        .get();

    final utilisateurs = snapshot.docs
        .map(
          (doc) => UtilisateurModel.fromMap(
        doc.data(),
        doc.id,
      ),
    )
        .toList();

    utilisateurs.sort(
          (a, b) => a.nomComplet
          .toLowerCase()
          .compareTo(
        b.nomComplet.toLowerCase(),
      ),
    );

    return utilisateurs;
  }

  /// ===========================
  /// Tous les utilisateurs
  /// ===========================
  Future<List<UtilisateurModel>> getTousLesUtilisateurs() async {
    final snapshot = await _firestore
        .collection(_collection)
        .get();

    final utilisateurs = snapshot.docs
        .map(
          (doc) => UtilisateurModel.fromMap(
        doc.data(),
        doc.id,
      ),
    )
        .toList();

    utilisateurs.sort(
          (a, b) => a.nomComplet
          .toLowerCase()
          .compareTo(
        b.nomComplet.toLowerCase(),
      ),
    );

    return utilisateurs;
  }

  /// ===========================
  /// Utilisateurs par rôle
  /// ===========================
  Future<List<UtilisateurModel>> getUtilisateursByRole(
      String role,
      ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
      'role',
      isEqualTo: role,
    )
        .where(
      'actif',
      isEqualTo: true,
    )
        .get();

    final utilisateurs = snapshot.docs
        .map(
          (doc) => UtilisateurModel.fromMap(
        doc.data(),
        doc.id,
      ),
    )
        .toList();

    utilisateurs.sort(
          (a, b) => a.nomComplet
          .toLowerCase()
          .compareTo(
        b.nomComplet.toLowerCase(),
      ),
    );

    return utilisateurs;
  }

  /// ===========================
  /// Utilisateurs par bergerie
  /// ===========================
  Future<List<UtilisateurModel>> getUtilisateursByBergerie(
      String bergerieId,
      ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
      'bergerieId',
      isEqualTo: bergerieId,
    )
        .where(
      'actif',
      isEqualTo: true,
    )
        .get();

    final utilisateurs = snapshot.docs
        .map(
          (doc) => UtilisateurModel.fromMap(
        doc.data(),
        doc.id,
      ),
    )
        .toList();

    utilisateurs.sort(
          (a, b) => a.nomComplet
          .toLowerCase()
          .compareTo(
        b.nomComplet.toLowerCase(),
      ),
    );

    return utilisateurs;
  }

  /// ===========================
  /// Nombre d'utilisateurs actifs
  /// ===========================
  Future<int> getNombreUtilisateurs() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
      'actif',
      isEqualTo: true,
    )
        .get();

    return snapshot.docs.length;
  }

  /// ===========================
  /// Vérifier si un téléphone existe
  /// ===========================
  Future<bool> telephoneExiste(
      String telephone,
      ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
      'telephone',
      isEqualTo: telephone,
    )
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// ===========================
  /// Générer l'email technique
  /// ===========================
  String genererEmailTechnique(
      String telephone,
      ) {
    final numero = telephone
        .replaceAll(" ", "")
        .replaceAll("-", "")
        .replaceAll("+", "");

    return "$numero@setsi.local";
  }

  /// ===========================
  /// Mettre à jour la dernière connexion
  /// ===========================
  Future<void> updateDerniereConnexion(
      String utilisateurId,
      DateTime date,
      ) async {
    await _firestore
        .collection(_collection)
        .doc(utilisateurId)
        .update({
      "derniereConnexion": date.toIso8601String(),
    });
  }

  /// ===========================
  /// Flux des utilisateurs actifs
  /// ===========================
  Stream<List<UtilisateurModel>> streamUtilisateurs() {
    return _firestore
        .collection(_collection)
        .where(
      'actif',
      isEqualTo: true,
    )
        .snapshots()
        .map((snapshot) {
      final utilisateurs = snapshot.docs
          .map(
            (doc) => UtilisateurModel.fromMap(
          doc.data(),
          doc.id,
        ),
      )
          .toList();

      utilisateurs.sort(
            (a, b) => a.nomComplet
            .toLowerCase()
            .compareTo(
          b.nomComplet.toLowerCase(),
        ),
      );

      return utilisateurs;
    });
  }

  /// ===========================
  /// Flux d'un utilisateur
  /// ===========================
  Stream<UtilisateurModel?> streamUtilisateur(
      String id,
      ) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UtilisateurModel.fromMap(
        doc.data()!,
        doc.id,
      );
    });
  }

  /// ===========================
  /// Charger l'utilisateur connecté
  /// ===========================
  Future<UtilisateurModel?> getCurrentUtilisateur(
      String uid,
      ) async {
    return getUtilisateurById(uid);
  }
}