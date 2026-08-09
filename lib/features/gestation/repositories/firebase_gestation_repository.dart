import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/gestation_model.dart';

class FirebaseGestationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'gestations';

  // Statut réellement utilisé dans Firestore pour une gestation en cours.
  static const String _statutGestante = 'Gestante';

  CollectionReference<Map<String, dynamic>> get _gestations =>
      _firestore.collection(_collection);

  Future<List<GestationModel>> getGestations() async {
    final snapshot = await _gestations
        .orderBy('dateCreation', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => GestationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<GestationModel>> watchGestations() {
    return _gestations
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => GestationModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<GestationModel?> getGestationById(String id) async {
    final doc = await _gestations.doc(id).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return GestationModel.fromMap(doc.data()!, doc.id);
  }

  Future<GestationModel?> getGestationActiveByBrebis(String brebisId) async {
    final snapshot = await _gestations
        .where('brebisId', isEqualTo: brebisId)
        .where('statut', isEqualTo: _statutGestante)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final doc = snapshot.docs.first;
    return GestationModel.fromMap(doc.data(), doc.id);
  }

  Future<void> addGestation(GestationModel gestation) async {
    await _gestations.doc(gestation.id).set(gestation.toMap());
  }

  Future<void> updateGestation(GestationModel gestation) async {
    await _gestations.doc(gestation.id).update(gestation.toMap());
  }

  Future<void> deleteGestation(String id) async {
    await _gestations.doc(id).delete();
  }

  Future<List<GestationModel>> getGestationsByMouton(String brebisId) async {
    final snapshot = await _gestations
        .where('brebisId', isEqualTo: brebisId)
        .orderBy('dateCreation', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => GestationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<GestationModel>> getGestationsEnCours() async {
    final snapshot = await _gestations
        .where('statut', isEqualTo: _statutGestante)
        .orderBy('dateCreation', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => GestationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<GestationModel>> getGestationsParBergerie(
      String bergerieId,
      ) async {
    try {
      final snapshot = await _gestations
          .where('bergerieId', isEqualTo: bergerieId)
          .get();

      return snapshot.docs
          .map((doc) => GestationModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<GestationModel>> getGestationsActives() async {
    return getGestationsEnCours();
  }

  Future<int> getNombreGestations() async {
    final snapshot = await _gestations.get();
    return snapshot.size;
  }

  Future<int> getNombreGestationsEnCours() async {
    final snapshot = await _gestations
        .where('statut', isEqualTo: _statutGestante)
        .get();

    return snapshot.size;
  }

  Future<int> getNombreGestationsTerminees() async {
    final snapshot = await _gestations
        .where('statut', isEqualTo: 'Terminée')
        .get();

    return snapshot.size;
  }

  Future<List<GestationModel>> rechercherGestations(String recherche) async {
    final liste = await getGestations();
    final filtre = recherche.trim().toLowerCase();

    return liste.where((g) {
      return g.nomFemelle.toLowerCase().contains(filtre) ||
          g.belierNom.toLowerCase().contains(filtre) ||
          g.statut.toLowerCase().contains(filtre);
    }).toList();
  }

  Future<void> annulerGestation(String id) async {
    await _gestations.doc(id).update({
      'statut': 'Annulée',
      'active': false,
      'dateModification': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> reactiverGestation(String id) async {
    await _gestations.doc(id).update({
      'statut': _statutGestante,
      'active': true,
      'dateModification': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> terminerGestation({
    required String id,
    required DateTime dateMiseBas,
    required int nombrePetits,
    required int males,
    required int femelles,
  }) async {
    await _gestations.doc(id).update({
      'statut': 'Terminée',
      'dateMiseBas': Timestamp.fromDate(dateMiseBas),
      'nombreAgneaux': nombrePetits,
      'nombreMales': males,
      'nombreFemelles': femelles,
      'active': false,
      'dateModification': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> enregistrerMiseBas({
    required String gestationId,
    required DateTime dateMiseBas,
    required int nombreAgneaux,
    required int nombreMales,
    required int nombreFemelles,
    required int nombreMortNes,
    String observations = '',
  }) async {
    await _gestations.doc(gestationId).update({
      'statut': 'Terminée',
      'dateMiseBas': Timestamp.fromDate(dateMiseBas),
      'nombreAgneaux': nombreAgneaux,
      'nombreMales': nombreMales,
      'nombreFemelles': nombreFemelles,
      'nombreMortNes': nombreMortNes,
      'observations': observations,
      'active': false,
      'dateModification': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> mettreAJourStatut({
    required String gestationId,
    required String statut,
  }) async {
    await _gestations.doc(gestationId).update({
      'statut': statut,
      'dateModification': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> cloturerGestation(String gestationId) async {
    await _gestations.doc(gestationId).update({
      'statut': 'Terminée',
      'active': false,
      'dateModification': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<int> getNombreGestationsEnRetard() async {
    final liste = await getGestationsEnCours();
    return liste.where((g) => g.estEnRetard).length;
  }

  Future<int> getNombreMisesBasProchaines() async {
    final liste = await getGestationsEnCours();

    return liste
        .where(
          (g) => g.joursRestants >= 0 && g.joursRestants <= 15,
    )
        .length;
  }
}
