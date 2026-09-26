import '../../features/interventions/models/intervention_model.dart';

class InterventionService {
  InterventionService._();

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
    final type = nettoyageBergerie
        ? 'Nettoyage de la bergerie'
        : desinfection
            ? 'Désinfection'
            : lavage
                ? 'Lavage'
                : 'Autre';

    return InterventionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bergerieId: '',
      type: type,
      date: dateIntervention,
      moutonId: null,
      moutonNom: null,
      observation: observations,
    );
  }
}
