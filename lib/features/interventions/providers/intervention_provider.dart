import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/intervention_model.dart';

class InterventionNotifier extends StateNotifier<List<InterventionModel>> {
  InterventionNotifier() : super(_initialData());

  static List<InterventionModel> _initialData() {
    return [
      InterventionModel(
        id: 'INT001',
        numero: 'INT-2026-0001',
        clientId: 'CL001',
        clientNom: 'Mamadou Ndiaye',
        dateIntervention: DateTime.now(),
        heureDebut: '08:00',
        heureFin: '10:00',
        lavage: true,
        nettoyageBergerie: true,
        desinfection: true,
        agent: 'Moussa',
        vehicule: 'Véhicule 01',
        nombreMoutons: 18,
        observations: 'Intervention planifiée.',
        statut: 'Planifiée',
      ),
      InterventionModel(
        id: 'INT002',
        numero: 'INT-2026-0002',
        clientId: 'CL002',
        clientNom: 'Ousmane Ba',
        dateIntervention: DateTime.now(),
        heureDebut: '10:30',
        heureFin: '12:00',
        lavage: true,
        nettoyageBergerie: false,
        desinfection: true,
        agent: 'Abdou',
        vehicule: 'Véhicule 02',
        nombreMoutons: 7,
        observations: 'Intervention en cours.',
        statut: 'En cours',
      ),
      InterventionModel(
        id: 'INT003',
        numero: 'INT-2026-0003',
        clientId: 'CL003',
        clientNom: 'Ibrahima Fall',
        dateIntervention: DateTime.now().add(
          const Duration(days: 1),
        ),
        heureDebut: '14:00',
        heureFin: '16:00',
        lavage: true,
        nettoyageBergerie: true,
        desinfection: false,
        agent: 'Cheikh',
        vehicule: 'Véhicule 01',
        nombreMoutons: 12,
        observations: 'Prévoir un traitement antiparasitaire.',
        statut: 'Terminée',
      ),
    ];
  }

  void addIntervention(InterventionModel intervention) {
    state = [...state, intervention];
  }

  void updateIntervention(InterventionModel intervention) {
    state = state.map((item) {
      return item.id == intervention.id ? intervention : item;
    }).toList();
  }

  void removeIntervention(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clear() {
    state = [];
  }
}

final interventionProvider =
StateNotifierProvider<InterventionNotifier, List<InterventionModel>>(
      (ref) => InterventionNotifier(),
);