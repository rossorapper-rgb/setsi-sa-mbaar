import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/session/current_user_service.dart';
import '../../clients/repositories/firebase_client_repository.dart';
import '../../auth/services/auth_service.dart';
import '../../bergeries/repository/firebase_bergerie_repository.dart';
import '../models/mouton_model.dart';

class FirebaseMoutonRepository {
  FirebaseMoutonRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'moutons';

  /// Ajouter un mouton
  Future<void> addMouton(MoutonModel mouton) async {
    await _firestore
        .collection(_collection)
        .doc(mouton.id)
        .set(mouton.toMap());
  }

  /// Modifier un mouton
  Future<void> updateMouton(MoutonModel mouton) async {
    await _firestore
        .collection(_collection)
        .doc(mouton.id)
        .update(mouton.toMap());
  }

  /// Archiver un mouton
  Future<void> archiveMouton(String id) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .update({
      'actif': false,
    });
  }

  /// Tous les moutons actifs
  Future<List<MoutonModel>> getMoutons() async {
    if (AuthService.instance.isAdmin ||
        AuthService.instance.isResponsable) {
      final snapshot = await _firestore
          .collection(_collection)
          .where('actif', isEqualTo: true)
          .get();

      final moutons = snapshot.docs
          .map(
            (doc) => MoutonModel.fromMap({
          ...doc.data(),
          'id': doc.id,
        }),
      )
          .toList();

      moutons.sort(
            (a, b) =>
            a.nom.toLowerCase().compareTo(
              b.nom.toLowerCase(),
            ),
      );

      return moutons;
    }

    final utilisateur = CurrentUserService.instance.currentUser;

    if (utilisateur == null) {
      return [];
    }

    // Le client est le propriétaire principal du mouton.
    // La bergerie est facultative.
    final clients = await FirebaseClientRepository().getClients();

    if (clients.isEmpty) {
      return [];
    }

    final clientId = clients.first.id;

    final snapshot = await _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .where('actif', isEqualTo: true)
        .get();

    final resultat = snapshot.docs
        .map(
          (doc) => MoutonModel.fromMap({
            ...doc.data(),
            'id': doc.id,
          }),
        )
        .toList();

    // Compatibilité avec les anciens moutons enregistrés avant clientId.
    final bergeries =
        await FirebaseBergerieRepository().getAllBergeries();

    final idsExistants = resultat.map((m) => m.id).toSet();

    for (final bergerie in bergeries) {
      final moutons =
          await getMoutonsByBergerie(bergerie.id);

      for (final mouton in moutons) {
        if (mouton.clientId.isEmpty &&
            !idsExistants.contains(mouton.id)) {
          resultat.add(mouton);
          idsExistants.add(mouton.id);
        }
      }
    }

    resultat.sort(
      (a, b) =>
          a.nom.toLowerCase().compareTo(
            b.nom.toLowerCase(),
          ),
    );

    return resultat;
  }

  /// Un mouton par son id
  Future<MoutonModel?> getMoutonById(String id) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(id)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return MoutonModel.fromMap({
      ...doc.data()!,
      'id': doc.id,
    });
  }

  /// Tous les moutons d'une bergerie
  Future<List<MoutonModel>> getMoutonsByBergerie(
      String bergerieId,
      ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('bergerieId', isEqualTo: bergerieId)
        .where('actif', isEqualTo: true)
        .get();

    final moutons = snapshot.docs
        .map(
          (doc) => MoutonModel.fromMap({
        ...doc.data(),
        'id': doc.id,
      }),
    )
        .toList();

    moutons.sort(
          (a, b) =>
          a.nom.toLowerCase().compareTo(
            b.nom.toLowerCase(),
          ),
    );

    return moutons;
  }

  /// Tous les moutons d'un client.
  /// La bergerie n'est pas obligatoire.
  Future<List<MoutonModel>> getMoutonsByClient(
      String clientId,
      ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .where('actif', isEqualTo: true)
        .get();

    final moutons = snapshot.docs
        .map(
          (doc) => MoutonModel.fromMap({
            ...doc.data(),
            'id': doc.id,
          }),
        )
        .toList();

    moutons.sort(
      (a, b) =>
          a.nom.toLowerCase().compareTo(
            b.nom.toLowerCase(),
          ),
    );

    return moutons;
  }

  /// Moutons du client qui ne sont rattachés à aucune bergerie.
  Future<List<MoutonModel>> getMoutonsSansBergerie(
      String clientId,
      ) async {
    final moutons = await getMoutonsByClient(clientId);

    return moutons
        .where(
          (mouton) => mouton.bergerieId.trim().isEmpty,
        )
        .toList();
  }

  /// Nombre de moutons d'une bergerie
  Future<int> getNombreMoutons(
      String bergerieId,
      ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('bergerieId', isEqualTo: bergerieId)
        .where('actif', isEqualTo: true)
        .get();

    return snapshot.docs.length;
  }

  /// Tous les béliers actifs
  Future<List<MoutonModel>> getBeliers() async {
    final moutons = await getMoutons();

    return moutons.where((m) {
      final sexe = m.sexe.toLowerCase();

      return sexe == 'male' || sexe == 'mâle';
    }).toList();
  }

  /// Toutes les brebis actives
  Future<List<MoutonModel>> getBrebis() async {
    final moutons = await getMoutons();

    return moutons.where((m) {
      return m.sexe.toLowerCase() == 'femelle';
    }).toList();
  }

  /// Toutes les brebis d'une bergerie
  Future<List<MoutonModel>> getBrebisByBergerie(
      String bergerieId,
      ) async {
    final moutons = await getMoutonsByBergerie(
      bergerieId,
    );

    return moutons.where((m) {
      return m.sexe.toLowerCase() == 'femelle';
    }).toList();
  }

  /// Tous les béliers d'une bergerie
  Future<List<MoutonModel>> getBeliersByBergerie(
      String bergerieId,
      ) async {
    final moutons = await getMoutonsByBergerie(
      bergerieId,
    );

    return moutons.where((m) {
      final sexe = m.sexe.toLowerCase();

      return sexe == 'male' || sexe == 'mâle';
    }).toList();
  }

  /// Supprimer (archiver) un mouton
  Future<void> deleteMouton(String id) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .update({
      'actif': false,
    });
  }
}