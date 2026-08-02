import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/veterinaire_model.dart';

class FirebaseVeterinaireRepository {
  FirebaseVeterinaireRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'veterinaires';

  /// Ajouter un vétérinaire
  Future<void> addVeterinaire(
      VeterinaireModel veterinaire,
      ) async {
    await _firestore
        .collection(_collection)
        .doc(veterinaire.id)
        .set(veterinaire.toMap());
  }

  /// Modifier un vétérinaire
  Future<void> updateVeterinaire(
      VeterinaireModel veterinaire,
      ) async {
    await _firestore
        .collection(_collection)
        .doc(veterinaire.id)
        .update(veterinaire.toMap());
  }

  /// Activer / Désactiver
  Future<void> setDisponibilite({
    required String id,
    required bool disponible,
  }) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .update({
      'disponible': disponible,
    });
  }

  /// Tous les vétérinaires
  Future<List<VeterinaireModel>> getVeterinaires() async {
    final snapshot = await _firestore
        .collection(_collection)
        .get();

    final veterinaires = snapshot.docs
        .map(
          (doc) => VeterinaireModel.fromMap({
        ...doc.data(),
        'id': doc.id,
      }),
    )
        .toList();

    veterinaires.sort(
          (a, b) => a.nom
          .toLowerCase()
          .compareTo(
        b.nom.toLowerCase(),
      ),
    );

    return veterinaires;
  }

  /// Seulement les vétérinaires disponibles
  Future<List<VeterinaireModel>>
  getVeterinairesDisponibles() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
      'disponible',
      isEqualTo: true,
    )
        .get();

    final veterinaires = snapshot.docs
        .map(
          (doc) => VeterinaireModel.fromMap({
        ...doc.data(),
        'id': doc.id,
      }),
    )
        .toList();

    veterinaires.sort(
          (a, b) => a.nom
          .toLowerCase()
          .compareTo(
        b.nom.toLowerCase(),
      ),
    );

    return veterinaires;
  }

  /// Recherche par région
  Future<List<VeterinaireModel>>
  getVeterinairesParRegion(
      String region,
      ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
      'region',
      isEqualTo: region,
    )
        .where(
      'disponible',
      isEqualTo: true,
    )
        .get();

    final veterinaires = snapshot.docs
        .map(
          (doc) => VeterinaireModel.fromMap({
        ...doc.data(),
        'id': doc.id,
      }),
    )
        .toList();

    veterinaires.sort(
          (a, b) => a.nom
          .toLowerCase()
          .compareTo(
        b.nom.toLowerCase(),
      ),
    );

    return veterinaires;
  }
}