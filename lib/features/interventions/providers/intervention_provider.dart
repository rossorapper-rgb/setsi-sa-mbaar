import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/intervention_model.dart';
import '../repositories/firebase_intervention_repository.dart';

final interventionRepositoryProvider = Provider<FirebaseInterventionRepository>(
  (ref) => FirebaseInterventionRepository(),
);

class InterventionNotifier
    extends StateNotifier<AsyncValue<List<InterventionModel>>> {
  InterventionNotifier(this._repository) : super(const AsyncLoading()) {
    chargerInterventions();
  }

  final FirebaseInterventionRepository _repository;

  Future<void> chargerInterventions() async {
    try {
      final interventions = await _repository.getToutesLesInterventions();
      state = AsyncData(interventions);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> ajouterIntervention({
    required String type,
    required DateTime date,
    String? moutonId,
    String? moutonNom,
    String observation = '',
  }) async {
    await _repository.ajouter(
      type: type,
      date: date,
      moutonId: moutonId,
      moutonNom: moutonNom,
      observation: observation,
    );
    await chargerInterventions();
  }

  Future<void> modifierIntervention(InterventionModel intervention) async {
    await _repository.modifier(intervention);
    await chargerInterventions();
  }

  Future<void> supprimerIntervention(String id) async {
    await _repository.supprimer(id);
    await chargerInterventions();
  }

  Future<void> rafraichir() => chargerInterventions();
}

final interventionProvider = StateNotifierProvider<InterventionNotifier,
    AsyncValue<List<InterventionModel>>>((ref) {
  return InterventionNotifier(ref.read(interventionRepositoryProvider));
});
