import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/session/current_user_service.dart';
import '../../auth/services/auth_service.dart';
import '../../clients/repositories/firebase_client_repository.dart';
import '../../../core/services/code_generator_service.dart';
import '../models/intervention_model.dart';

class FirebaseInterventionRepository {
FirebaseInterventionRepository({
FirebaseFirestore? firestore,
}) : _firestore = firestore ?? FirebaseFirestore.instance;

final FirebaseFirestore _firestore;

CollectionReference<Map<String, dynamic>> get _collection =>
_firestore.collection('interventions');

//====================================================
// AJOUTER UNE INTERVENTION
//====================================================

Future<InterventionModel> createIntervention({
required String clientId,
required String clientNom,
  required String bergerieId,
  required String bergerieNom,
required DateTime dateIntervention,
required String heureDebut,
required String heureFin,
required bool lavage,
required bool nettoyageBergerie,
required bool desinfection,
required String agent,
required String vehicule,
required int nombreMoutons,
  String? abonnementId,
  List<String> moutonsConcernes = const [],

  bool vermifugation = false,
  String produitVermifuge = "",
  DateTime? prochaineVermifugation,

  bool traitementEnCours = false,
  String maladie = "",
  DateTime? finTraitement,

  String recommandations = "",
String observations = "",
}) async {
final doc = _collection.doc();

final numero = await CodeGeneratorService.generate(
prefix: "INT",
);

final intervention = InterventionModel(
id: doc.id,
numero: numero,
  clientId: clientId,
  clientNom: clientNom,

  bergerieId: bergerieId,
  bergerieNom: bergerieNom,

  origineIntervention: "Ponctuelle",
  abonnementId: abonnementId,
  dateIntervention: dateIntervention,
heureDebut: heureDebut,
heureFin: heureFin,
lavage: lavage,
nettoyageBergerie: nettoyageBergerie,
desinfection: desinfection,
agent: agent,
vehicule: vehicule,
nombreMoutons: nombreMoutons,
  moutonsConcernes: moutonsConcernes,

  vermifugation: vermifugation,
  produitVermifuge: produitVermifuge,
  prochaineVermifugation:
  prochaineVermifugation,

  traitementEnCours:
  traitementEnCours,
  maladie: maladie,
  finTraitement: finTraitement,
observations: observations,
  recommandations: recommandations,
statut: "Planifiée",
);

await doc.set(intervention.toMap());

return intervention;
}

//====================================================
// MODIFIER
//====================================================

Future<void> updateIntervention(
InterventionModel intervention,
) async {
await _collection
.doc(intervention.id)
.update(intervention.toMap());
}

//====================================================
// SUPPRIMER
//====================================================

Future<void> deleteIntervention(
String id,
) async {
await _collection
.doc(id)
.delete();
}

//====================================================
// UNE INTERVENTION
//====================================================

Future<InterventionModel?> getIntervention(
String id,
) async {
final doc = await _collection.doc(id).get();

if (!doc.exists) {
return null;
}

return InterventionModel.fromMap(
doc.data()!,
);
}
//====================================================
// TOUTES LES INTERVENTIONS
//====================================================

Future<List<InterventionModel>> getToutesLesInterventions() async {
  if (AuthService.instance.isAdmin ||
      AuthService.instance.isResponsable) {
    final snapshot = await _collection.get();

    final liste = snapshot.docs
        .map(
          (doc) => InterventionModel.fromMap(
        doc.data(),
      ),
    )
        .toList();

    liste.sort(
          (a, b) => b.dateIntervention.compareTo(
        a.dateIntervention,
      ),
    );

    return liste;
  }

  final utilisateur = CurrentUserService.instance.currentUser;

  if (utilisateur == null) {
    return [];
  }

  final clients =
  await FirebaseClientRepository().getClients();

  if (clients.isEmpty) {
    return [];
  }

  final client = clients.first;

  return getInterventionsDuClient(client.id);
}

//====================================================
// INTERVENTIONS D'UN CLIENT
//====================================================

Future<List<InterventionModel>> getInterventionsDuClient(
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
(doc) => InterventionModel.fromMap(
doc.data(),
),
)
.toList();

liste.sort(
(a, b) => b.dateIntervention.compareTo(
a.dateIntervention,
),
);

return liste;
}

//====================================================
// INTERVENTIONS DU JOUR
//====================================================

Future<List<InterventionModel>> getInterventionsDuJour() async {
final toutes = await getToutesLesInterventions();

final aujourdHui = DateTime.now();

return toutes.where((intervention) {
return intervention.dateIntervention.year ==
aujourdHui.year &&
intervention.dateIntervention.month ==
aujourdHui.month &&
intervention.dateIntervention.day ==
aujourdHui.day;
}).toList();
}

//====================================================
// INTERVENTIONS PAR STATUT
//====================================================

Future<List<InterventionModel>> getInterventionsParStatut(
String statut,
) async {
final snapshot = await _collection
.where(
'statut',
isEqualTo: statut,
)
.get();

final liste = snapshot.docs
.map(
(doc) => InterventionModel.fromMap(
doc.data(),
),
)
.toList();

liste.sort(
(a, b) => b.dateIntervention.compareTo(
a.dateIntervention,
),
);

return liste;
}
  //====================================================
  // CHANGER LE STATUT
  //====================================================

  Future<void> updateStatut({
    required String interventionId,
    required String statut,
  }) async {
    await _collection.doc(interventionId).update({
      'statut': statut,
    });
  }

  //====================================================
  // NOMBRE TOTAL
  //====================================================

  Future<int> getNombreInterventions() async {
    final snapshot = await _collection.get();
    return snapshot.docs.length;
  }

  //====================================================
  // NOMBRE PAR STATUT
  //====================================================

  Future<int> getNombreParStatut(
      String statut,
      ) async {
    final snapshot = await _collection
        .where(
      'statut',
      isEqualTo: statut,
    )
        .get();

    return snapshot.docs.length;
  }

  //====================================================
  // STATISTIQUES DASHBOARD
  //====================================================

  Future<Map<String, int>> getStatistiques() async {
    final planifiees =
    await getNombreParStatut('Planifiée');

    final enCours =
    await getNombreParStatut('En cours');

    final terminees =
    await getNombreParStatut('Terminée');

    return {
      'planifiees': planifiees,
      'enCours': enCours,
      'terminees': terminees,
      'total':
      planifiees + enCours + terminees,
    };
  }

  //====================================================
  // RECHARGER
  //====================================================

  Future<List<InterventionModel>> refresh() {
    return getToutesLesInterventions();
  }
}