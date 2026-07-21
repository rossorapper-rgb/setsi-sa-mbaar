import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/intervention_model.dart';

final interventionProvider = Provider<List<InterventionModel>>((ref) {
  return const [
    InterventionModel(
      id: "INT001",
      heure: "08:30",
      client: "Mamadou Ndiaye",
      quartier: "Grand Yoff",
      service: "Pack Prestige",
      statut: "En cours",
    ),
    InterventionModel(
      id: "INT002",
      heure: "10:00",
      client: "Ousmane Ba",
      quartier: "Yoff",
      service: "Lavage complet",
      statut: "Terminée",
    ),
    InterventionModel(
      id: "INT003",
      heure: "14:30",
      client: "Cheikh Fall",
      quartier: "Parcelles",
      service: "Désinfection",
      statut: "À venir",
    ),
  ];
});