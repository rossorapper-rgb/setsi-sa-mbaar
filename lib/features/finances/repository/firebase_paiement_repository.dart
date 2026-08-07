import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/code_generator_service.dart';
import '../models/paiement_model.dart';

class FirebasePaiementRepository {
  FirebasePaiementRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('paiements');

  //====================================================
  // AJOUTER UN PAIEMENT
  //====================================================

  Future<PaiementModel> createPaiement({
    required String clientId,
    required String clientNom,
    required String bergerieId,
    required String bergerieNom,
    String? interventionId,
    required TypePrestation typePrestation,
    String abonnement = "",
    required double montantConseille,
    required double montantFacture,
    required double montantPaye,
    required ModePaiement modePaiement,
    String reference = "",
    String motifRemise = "",
    String observations = "",
    required String creePar,
    required DateTime datePaiement,
  }) async {
    final doc = _collection.doc();

    final numeroFacture = await CodeGeneratorService.generate(
      prefix: "FAC",
    );

    final maintenant = DateTime.now();

    final paiement = PaiementModel(
      id: doc.id,
      numeroFacture: numeroFacture,
      clientId: clientId,
      clientNom: clientNom,
      bergerieId: bergerieId,
      bergerieNom: bergerieNom,
      interventionId: interventionId,
      typePrestation: typePrestation,
      abonnement: abonnement,
      montantConseille: montantConseille,
      montantFacture: montantFacture,
      montantPaye: montantPaye,
      modePaiement: modePaiement,
      reference: reference,
      motifRemise: motifRemise,
      observations: observations,
      actif: true,
      creePar: creePar,
      datePaiement: datePaiement,
      dateCreation: maintenant,
      dateModification: maintenant,
    );

    await doc.set(paiement.toMap());

    return paiement;
  }

  //====================================================
  // MODIFIER
  //====================================================

  Future<void> updatePaiement(
      PaiementModel paiement,
      ) async {
    await _collection.doc(paiement.id).update(
      paiement
          .copyWith(
        dateModification: DateTime.now(),
      )
          .toMap(),
    );
  }

  //====================================================
  // ANNULER
  //====================================================

  Future<void> annulerPaiement(
      String id,
      ) async {
    await _collection.doc(id).update({
      'actif': false,
      'dateModification':
      DateTime.now().toIso8601String(),
    });
  }

  //====================================================
  // UN PAIEMENT
  //====================================================

  Future<PaiementModel?> getPaiement(
      String id,
      ) async {
    final doc = await _collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return PaiementModel.fromMap(doc.data()!);
  }

  //====================================================
  // TOUS LES PAIEMENTS
  //====================================================

  Future<List<PaiementModel>> getTousLesPaiements() async {
    final snapshot = await _collection.get();

    final liste = snapshot.docs
        .map(
          (doc) => PaiementModel.fromMap(
        doc.data(),
      ),
    )
        .toList();

    liste.sort(
          (a, b) =>
          b.datePaiement.compareTo(a.datePaiement),
    );

    return liste;
  }

  //====================================================
  // PAIEMENTS D'UN CLIENT
  //====================================================

  Future<List<PaiementModel>> getPaiementsDuClient(
      String clientId,
      ) async {
    final snapshot = await _collection
        .where(
      'clientId',
      isEqualTo: clientId,
    )
        .get();

    final liste = snapshot.docs
        .map(
          (doc) => PaiementModel.fromMap(
        doc.data(),
      ),
    )
        .toList();

    liste.sort(
          (a, b) =>
          b.datePaiement.compareTo(a.datePaiement),
    );

    return liste;
  }

  //====================================================
  // PAIEMENTS ACTIFS
  //====================================================

  Future<List<PaiementModel>> getPaiementsActifs() async {
    final snapshot = await _collection
        .where(
      'actif',
      isEqualTo: true,
    )
        .get();

    final liste = snapshot.docs
        .map(
          (doc) => PaiementModel.fromMap(
        doc.data(),
      ),
    )
        .toList();

    liste.sort(
          (a, b) =>
          b.datePaiement.compareTo(a.datePaiement),
    );

    return liste;
  }

  //====================================================
  // NOMBRE TOTAL
  //====================================================

  Future<int> getNombrePaiements() async {
    final snapshot = await _collection.get();
    return snapshot.docs.length;
  }

  //====================================================
  // REVENU TOTAL
  //====================================================

  Future<double> getRevenuTotal() async {
    final liste = await getPaiementsActifs();

    return liste.fold<double>(
      0.0,
          (total, paiement) =>
      total + paiement.montantPaye,
    );
  }

  //====================================================
  // REVENUS DU JOUR
  //====================================================

  Future<double> getRevenuDuJour() async {
    final liste = await getPaiementsActifs();

    final aujourdHui = DateTime.now();

    return liste
        .where(
          (paiement) =>
      paiement.datePaiement.year ==
          aujourdHui.year &&
          paiement.datePaiement.month ==
              aujourdHui.month &&
          paiement.datePaiement.day ==
              aujourdHui.day,
    )
        .fold<double>(
      0.0,
          (total, paiement) =>
      total + paiement.montantPaye,
    );
  }

  //====================================================
  // RECHARGER
  //====================================================

  Future<List<PaiementModel>> refresh() {
    return getTousLesPaiements();
  }
}