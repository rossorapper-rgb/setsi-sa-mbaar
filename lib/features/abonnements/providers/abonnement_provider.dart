import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/abonnement_model.dart';

class AbonnementNotifier extends StateNotifier<List<AbonnementModel>> {
  AbonnementNotifier() : super(_demoData());

  static List<AbonnementModel> _demoData() {
    return [
      AbonnementModel(
        id: '1',
        numero: 'ABN-0001',
        clientId: 'CL001',
        clientNom: 'Mamadou Ndiaye',
        bergerieId: 'BG001',
        bergerieNom: 'Bergerie Grand Yoff',
        pack: 'Prestige',
        montant: 40000,
        dateDebut: DateTime.now().subtract(const Duration(days: 10)),
        dateFin: DateTime.now().add(const Duration(days: 20)),
        montantPaye: 40000,
        resteAPayer: 0,
        statut: 'Actif',
        observations: '',
        dateCreation: DateTime.now(),
      ),
      AbonnementModel(
        id: '2',
        numero: 'ABN-0002',
        clientId: 'CL002',
        clientNom: 'Ousmane Ba',
        bergerieId: 'BG002',
        bergerieNom: 'Bergerie Parcelles',
        pack: 'Confort',
        montant: 25000,
        dateDebut: DateTime.now().subtract(const Duration(days: 5)),
        dateFin: DateTime.now().add(const Duration(days: 25)),
        montantPaye: 10000,
        resteAPayer: 15000,
        statut: 'Actif',
        observations: 'Paiement partiel',
        dateCreation: DateTime.now(),
      ),
    ];
  }

  void addAbonnement(AbonnementModel abonnement) {
    state = [...state, abonnement];
  }

  void updateAbonnement(AbonnementModel abonnement) {
    state = [
      for (final a in state)
        if (a.id == abonnement.id) abonnement else a,
    ];
  }

  void deleteAbonnement(String id) {
    state = state.where((a) => a.id != id).toList();
  }
}

final abonnementProvider =
    StateNotifierProvider<AbonnementNotifier, List<AbonnementModel>>(
  (ref) => AbonnementNotifier(),
);
