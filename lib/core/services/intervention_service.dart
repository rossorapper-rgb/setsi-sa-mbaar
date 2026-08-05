import '../../features/interventions/models/intervention_model.dart';

class InterventionService {
  InterventionService._();

  static int _compteur = 3;

  static InterventionModel creerIntervention({
    required String clientNom,
    required DateTime dateIntervention,
    required int nombreMoutons,
    required bool lavage,
    required bool nettoyageBergerie,
    required bool desinfection,
    required String agent,
    required String vehicule,
    required String observations,
  }) {
    _compteur++;

    final numero = "INT-2026-${_compteur.toString().padLeft(4, '0')}";

    return InterventionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      numero: numero,

      clientId: "",
      clientNom: clientNom,

      bergerieId: "",
      bergerieNom: "",

      origineIntervention: "Ponctuelle",

      dateIntervention: dateIntervention,
      heureDebut: "",
      heureFin: "",

      lavage: lavage,
      nettoyageBergerie: nettoyageBergerie,
      desinfection: desinfection,

      agent: agent,
      vehicule: vehicule,

      nombreMoutons: nombreMoutons,

      observations: observations,

      statut: "Planifiée",
    );
  }
}