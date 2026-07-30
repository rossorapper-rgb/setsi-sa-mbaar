import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/intervention_model.dart';
import '../repositories/firebase_intervention_repository.dart';

final interventionRepositoryProvider =
Provider<FirebaseInterventionRepository>(
      (ref) => FirebaseInterventionRepository(),
);

class InterventionNotifier
    extends StateNotifier<AsyncValue<List<InterventionModel>>> {
InterventionNotifier(this._repository)
: super(const AsyncLoading()) {
chargerInterventions();
}

final FirebaseInterventionRepository _repository;

Future<void> chargerInterventions() async {
try {
final interventions =
await _repository.getToutesLesInterventions();

state = AsyncData(interventions);
} catch (e, st) {
state = AsyncError(e, st);
}
}

Future<void> ajouterIntervention({
required String clientId,
required String clientNom,
required DateTime dateIntervention,
required String heureDebut,
required String heureFin,
required bool lavage,
required bool nettoyageBergerie,
required bool desinfection,
required String agent,
required String vehicule,
required int nombreMoutons,
String observations = "",
}) async {
try {
await _repository.createIntervention(
clientId: clientId,
clientNom: clientNom,
dateIntervention: dateIntervention,
heureDebut: heureDebut,
heureFin: heureFin,
lavage: lavage,
nettoyageBergerie: nettoyageBergerie,
desinfection: desinfection,
agent: agent,
vehicule: vehicule,
nombreMoutons: nombreMoutons,
observations: observations,
);

await chargerInterventions();
} catch (e) {
rethrow;
}
}

Future<void> modifierIntervention(
InterventionModel intervention,
) async {
try {
await _repository.updateIntervention(
intervention,
);

await chargerInterventions();
} catch (e) {
rethrow;
}
}
Future<void> supprimerIntervention(
    String id,
    ) async {
  try {
    await _repository.deleteIntervention(id);

    await chargerInterventions();
  } catch (e) {
    rethrow;
  }
}

Future<void> changerStatut({
  required String interventionId,
  required String statut,
}) async {
  try {
    await _repository.updateStatut(
      interventionId: interventionId,
      statut: statut,
    );

    await chargerInterventions();
  } catch (e) {
    rethrow;
  }
}

Future<void> rafraichir() async {
  await chargerInterventions();
}
}

final interventionProvider = StateNotifierProvider<
    InterventionNotifier,
    AsyncValue<List<InterventionModel>>>(
      (ref) {
    return InterventionNotifier(
      ref.read(interventionRepositoryProvider),
    );
  },
);