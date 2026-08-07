import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/paiement_model.dart';
import '../repository/firebase_paiement_repository.dart';

final paiementRepositoryProvider =
Provider<FirebasePaiementRepository>(
      (ref) => FirebasePaiementRepository(),
);

class PaiementNotifier
    extends StateNotifier<AsyncValue<List<PaiementModel>>> {
  PaiementNotifier(this._repository)
      : super(const AsyncLoading()) {
    chargerPaiements();
  }

  final FirebasePaiementRepository _repository;

  Future<void> chargerPaiements() async {
    try {
      final paiements =
      await _repository.getTousLesPaiements();

      state = AsyncData(paiements);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> ajouterPaiement({
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
    try {
      await _repository.createPaiement(
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
        creePar: creePar,
        datePaiement: datePaiement,
      );

      await chargerPaiements();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> modifierPaiement(
      PaiementModel paiement,
      ) async {
    try {
      await _repository.updatePaiement(
        paiement,
      );

      await chargerPaiements();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> annulerPaiement(
      String id,
      ) async {
    try {
      await _repository.annulerPaiement(id);

      await chargerPaiements();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rafraichir() async {
    await chargerPaiements();
  }
}

final paiementProvider = StateNotifierProvider<
    PaiementNotifier,
    AsyncValue<List<PaiementModel>>>(
      (ref) {
    return PaiementNotifier(
      ref.read(paiementRepositoryProvider),
    );
  },
);