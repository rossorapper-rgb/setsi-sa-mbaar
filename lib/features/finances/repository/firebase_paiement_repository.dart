import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/current_user_service.dart';
import '../../../core/session/local_business_cache_service.dart';
import '../../auth/services/auth_service.dart';
import '../../clients/repositories/firebase_client_repository.dart';
import '../../../core/services/code_generator_service.dart';
import '../models/paiement_model.dart';

class FirebasePaiementRepository {
  FirebasePaiementRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final LocalBusinessCacheService _cache =
      LocalBusinessCacheService.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('paiements');

  String _cacheKey(String bergerieId) => 'paiements_$bergerieId';

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

    await _saveLocal(paiement);
    unawaited(_synchroniserAjout(doc, paiement));

    return paiement;
  }

  Future<void> updatePaiement(PaiementModel paiement) async {
    final updated = paiement.copyWith(
      dateModification: DateTime.now(),
    );

    await _saveLocal(updated);
    unawaited(_synchroniserModification(updated));
  }

  Future<void> annulerPaiement(String id) async {
    final utilisateur = CurrentUserService.instance.currentUser;
    final bergerieId = utilisateur?.bergerieId?.trim();

    if (bergerieId == null || bergerieId.isEmpty) {
      throw StateError('Aucune bergerie associée à cet utilisateur.');
    }

    final cached = await _loadLocal(bergerieId);
    final index = cached.indexWhere((item) => item.id == id);

    if (index < 0) {
      throw StateError('Paiement introuvable dans les données locales.');
    }

    final updated = cached[index].copyWith(
      actif: false,
      dateModification: DateTime.now(),
    );

    await _saveLocal(updated);
    unawaited(_synchroniserAnnulation(updated));
  }

  Future<PaiementModel?> getPaiement(String id) async {
    try {
      final doc = await _collection.doc(id).get();

      if (!doc.exists) return null;

      final paiement = PaiementModel.fromMap(doc.data()!);
      await _saveLocal(paiement);
      return paiement;
    } catch (_) {
      final utilisateur = CurrentUserService.instance.currentUser;
      final bergerieId = utilisateur?.bergerieId?.trim();
      if (bergerieId == null || bergerieId.isEmpty) return null;

      final cached = await _loadLocal(bergerieId);
      for (final paiement in cached) {
        if (paiement.id == id) return paiement;
      }
      return null;
    }
  }

  Future<List<PaiementModel>> getTousLesPaiements() async {
    final utilisateur = CurrentUserService.instance.currentUser;
    final bergerieId = utilisateur?.bergerieId?.trim();

    try {
      List<PaiementModel> liste;

      if (AuthService.instance.isAdmin ||
          AuthService.instance.isResponsable) {
        final snapshot = await _collection.get();
        liste = snapshot.docs
            .map((doc) => PaiementModel.fromMap(doc.data()))
            .toList();
      } else {
        if (utilisateur == null) return [];

        final clients = await FirebaseClientRepository().getClients();
        if (clients.isEmpty) return [];

        liste = await getPaiementsDuClient(clients.first.id);
      }

      liste.sort(
        (a, b) => b.datePaiement.compareTo(a.datePaiement),
      );

      if (bergerieId != null && bergerieId.isNotEmpty) {
        await _cache.saveList(
          _cacheKey(bergerieId),
          liste.map((p) => p.toMap()).toList(),
        );
      }

      return liste;
    } catch (_) {
      if (bergerieId == null || bergerieId.isEmpty) return [];

      final liste = await _loadLocal(bergerieId);
      liste.sort(
        (a, b) => b.datePaiement.compareTo(a.datePaiement),
      );
      return liste;
    }
  }

  Future<List<PaiementModel>> getPaiementsDuClient(String clientId) async {
    final snapshot = await _collection
        .where(
          'clientId',
          isEqualTo: clientId,
        )
        .get();

    final liste = snapshot.docs
        .map((doc) => PaiementModel.fromMap(doc.data()))
        .toList();

    liste.sort(
      (a, b) => b.datePaiement.compareTo(a.datePaiement),
    );

    return liste;
  }

  Future<List<PaiementModel>> getPaiementsActifs() async {
    final liste = await getTousLesPaiements();
    return liste.where((paiement) => paiement.actif).toList();
  }

  Future<int> getNombrePaiements() async {
    final liste = await getTousLesPaiements();
    return liste.length;
  }

  Future<double> getRevenuTotal() async {
    final liste = await getPaiementsActifs();
    return liste.fold<double>(
      0.0,
      (total, paiement) => total + paiement.montantPaye,
    );
  }

  Future<double> getRevenuDuJour() async {
    final liste = await getPaiementsActifs();

    final aujourdHui = DateTime.now();

    return liste
        .where(
          (paiement) =>
              paiement.datePaiement.year == aujourdHui.year &&
              paiement.datePaiement.month == aujourdHui.month &&
              paiement.datePaiement.day == aujourdHui.day,
        )
        .fold<double>(
          0.0,
          (total, paiement) => total + paiement.montantPaye,
        );
  }

  Future<List<PaiementModel>> refresh() {
    return getTousLesPaiements();
  }

  Future<List<PaiementModel>> _loadLocal(String bergerieId) async {
    final cached = await _cache.loadList(_cacheKey(bergerieId));
    if (cached == null) return [];

    return cached.map(PaiementModel.fromMap).toList();
  }

  Future<void> _saveLocal(PaiementModel paiement) async {
    final cached = await _loadLocal(paiement.bergerieId);
    final updated = [
      ...cached.where((item) => item.id != paiement.id),
      paiement,
    ];
    updated.sort((a, b) => b.datePaiement.compareTo(a.datePaiement));

    await _cache.saveList(
      _cacheKey(paiement.bergerieId),
      updated.map((item) => item.toMap()).toList(),
    );
  }

  Future<void> _synchroniserAjout(
    DocumentReference<Map<String, dynamic>> doc,
    PaiementModel paiement,
  ) async {
    try {
      await doc.set(paiement.toMap());
    } catch (_) {}
  }

  Future<void> _synchroniserModification(PaiementModel paiement) async {
    try {
      await _collection.doc(paiement.id).set(paiement.toMap());
    } catch (_) {}
  }

  Future<void> _synchroniserAnnulation(PaiementModel paiement) async {
    try {
      await _collection.doc(paiement.id).update({
        'actif': false,
        'dateModification': paiement.dateModification.toIso8601String(),
      });
    } catch (_) {}
  }
}
