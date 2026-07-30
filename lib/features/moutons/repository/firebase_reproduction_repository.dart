import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/code_generator_service.dart';
import '../models/mise_bas_model.dart';
import '../models/mouton_model.dart';
import '../models/reproduction_model.dart';

class FirebaseReproductionRepository {
FirebaseReproductionRepository({
FirebaseFirestore? firestore,
}) : _firestore =
firestore ??
FirebaseFirestore.instance;

final FirebaseFirestore _firestore;

CollectionReference<
Map<String, dynamic>>
get _reproductionCollection =>
_firestore.collection(
'reproductions',
);

CollectionReference<
Map<String, dynamic>>
get _moutonCollection =>
_firestore.collection(
'moutons',
);

CollectionReference<
Map<String, dynamic>>
get _miseBasCollection =>
_firestore.collection(
'mises_bas',
);

//====================================================
// CREER UNE REPRODUCTION
//====================================================

Future<ReproductionModel>
creerReproduction({
required MoutonModel mouton,
required DateTime dateSaillie,
required String belierId,
required String nomBelier,
required String raceBelier,
required String
proprietaireBelier,
String observations = "",
}) async {
final reproductionActive =
await getReproductionEnCours(
mouton.id,
);

if (reproductionActive != null) {
throw Exception(
"Cette brebis possède déjà une reproduction en cours.",
);
}

final document =
_reproductionCollection.doc();

final code =
await CodeGeneratorService
.generate(
prefix: "REP",
);

final reproduction =
ReproductionModel(
id: document.id,
code: code,
moutonId: mouton.id,
dateSaillie: dateSaillie,
belierId: belierId,
nomBelier: nomBelier,
raceBelier: raceBelier,
proprietaireBelier:
proprietaireBelier,
datePrevueMiseBas:
dateSaillie.add(
const Duration(days: 150),
),
observations: observations,
statut:
ReproductionStatut
.gestation,
dateCreation: DateTime.now(),
);

await document.set(
reproduction.toMap(),
);

return reproduction;
}
//====================================================
// MODIFIER
//====================================================

Future<void> modifierReproduction(
ReproductionModel reproduction,
) async {
await _reproductionCollection
.doc(reproduction.id)
.update(
reproduction.toMap(),
);
}

//====================================================
// SUPPRIMER
//====================================================

Future<void> supprimerReproduction(
String id,
) async {
await _reproductionCollection
.doc(id)
.delete();
}

//====================================================
// UNE REPRODUCTION
//====================================================

Future<ReproductionModel?>
getReproduction(
String id,
) async {
final doc =
await _reproductionCollection
.doc(id)
.get();

if (!doc.exists) {
return null;
}

return ReproductionModel.fromMap(
doc.data()!,
);
}

//====================================================
// HISTORIQUE
//====================================================

Future<List<ReproductionModel>>
getReproductionsDuMouton(
String moutonId,
) async {
final snapshot =
await _reproductionCollection
.where(
"moutonId",
isEqualTo: moutonId,
)
.get();

final liste = snapshot.docs
.map(
(e) =>
ReproductionModel.fromMap(
e.data(),
),
)
.toList();

liste.sort(
(a, b) => b.dateSaillie
.compareTo(a.dateSaillie),
);

return liste;
}

//====================================================
// REPRODUCTION EN COURS
//====================================================

Future<ReproductionModel?>
getReproductionEnCours(
String moutonId,
) async {
final reproductions =
await getReproductionsDuMouton(
moutonId,
);

try {
return reproductions.firstWhere(
(r) =>
r.statut ==
ReproductionStatut
.saillie ||
r.statut ==
ReproductionStatut
.gestation,
);
} catch (_) {
return null;
}
}
//====================================================
// CLOTURER UNE REPRODUCTION
//====================================================

Future<void> cloturerReproduction({
required ReproductionModel
reproduction,
required MoutonModel mere,
required DateTime dateMiseBas,
required int nombreMales,
required int nombreFemelles,
required double poidsNaissance,
required String couleur,
String observations = "",
}) async {
if (reproduction.statut ==
ReproductionStatut.terminee) {
throw Exception(
"Cette reproduction est déjà terminée.",
);
}

if (dateMiseBas.isBefore(
reproduction.dateSaillie,
)) {
throw Exception(
"La date de mise bas est invalide.",
);
}

final total =
nombreMales + nombreFemelles;

if (total <= 0) {
throw Exception(
"Le nombre d'agneaux doit être supérieur à zéro.",
);
}

//------------------------------------------
// Préparation avant transaction
//------------------------------------------

final miseBasDoc =
_miseBasCollection.doc();

final codeMiseBas =
await CodeGeneratorService
.generate(
prefix: "MB",
);

final miseBas = MiseBasModel(
id: miseBasDoc.id,
code: codeMiseBas,
reproductionId: reproduction.id,
moutonId: mere.id,
dateMiseBas: dateMiseBas,
nombreAgneaux: total,
nombreMales: nombreMales,
nombreFemelles:
nombreFemelles,
observations: observations,
dateCreation: DateTime.now(),
);

final List<MoutonModel>
agneaux = [];

for (int i = 0;
i < total;
i++) {
final code =
await CodeGeneratorService
.generate(
prefix: "MT",
);

final sexe =
i < nombreMales
? "Mâle"
: "Femelle";

agneaux.add(
MoutonModel(
id:
_moutonCollection.doc().id,
bergerieId:
mere.bergerieId,
nom: "Agneau ${i + 1}",
numeroIdentification:
code,
race: mere.race,
sexe: sexe,
dateNaissance:
dateMiseBas,
poids:
poidsNaissance,
couleur: couleur,
photoUrl: "",
actif: true,
dateCreation:
DateTime.now(),
),
);
}
//------------------------------------------
// Transaction Firestore
//------------------------------------------

await _firestore.runTransaction(
(transaction) async {
transaction.set(
miseBasDoc,
miseBas.toMap(),
);

transaction.update(
_reproductionCollection.doc(
reproduction.id,
),
{
"dateMiseBas":
dateMiseBas
.toIso8601String(),
"nombreAgneaux": total,
"nombreMales":
nombreMales,
"nombreFemelles":
nombreFemelles,
"statut":
ReproductionStatut
.terminee
.name,
"dateModification":
DateTime.now()
.toIso8601String(),
},
);

for (final agneau
in agneaux) {
transaction.set(
_moutonCollection.doc(
agneau.id,
),
agneau.toMap(),
);
}
},
);
}

//====================================================
// ENREGISTRER UNE MISE BAS (COMPATIBILITÉ)
//====================================================

Future<void> enregistrerMiseBas({
required String
reproductionId,
required DateTime
dateMiseBas,
required int
nombreAgneaux,
required int
nombreMales,
required int
nombreFemelles,
}) async {
await _reproductionCollection
.doc(reproductionId)
.update({
"dateMiseBas":
dateMiseBas
.toIso8601String(),
"nombreAgneaux":
nombreAgneaux,
"nombreMales":
nombreMales,
"nombreFemelles":
nombreFemelles,
"statut":
ReproductionStatut
.terminee
.name,
"dateModification":
DateTime.now()
.toIso8601String(),
});
}
//====================================================
// HISTORIQUE DES MISES BAS
//====================================================

Future<List<MiseBasModel>>
getMisesBasDuMouton(
String moutonId,
) async {
final snapshot =
await _miseBasCollection
.where(
"moutonId",
isEqualTo: moutonId,
)
.get();

final liste = snapshot.docs
.map(
(e) =>
MiseBasModel.fromMap(
e.data(),
),
)
.toList();

liste.sort(
(a, b) => b.dateMiseBas
.compareTo(a.dateMiseBas),
);

return liste;
}

//====================================================
// UNE MISE BAS
//====================================================

Future<MiseBasModel?>
getMiseBas(
String id,
) async {
final doc =
await _miseBasCollection
.doc(id)
.get();

if (!doc.exists) {
return null;
}

return MiseBasModel.fromMap(
doc.data()!,
);
}
//====================================================
// TOUTES LES MISES BAS
//====================================================

Future<List<MiseBasModel>>
getToutesLesMisesBas() async {
final snapshot =
await _miseBasCollection
.get();

final liste = snapshot.docs
.map(
(e) =>
MiseBasModel.fromMap(
e.data(),
),
)
.toList();

liste.sort(
(a, b) => b.dateMiseBas
.compareTo(a.dateMiseBas),
);

return liste;
}

//====================================================
// TOUTES LES REPRODUCTIONS
//====================================================

Future<List<ReproductionModel>>
getToutesLesReproductions() async {
final snapshot =
await _reproductionCollection
.get();

final liste = snapshot.docs
.map(
(doc) =>
ReproductionModel.fromMap(
doc.data(),
),
)
.toList();

liste.sort(
(a, b) => b.dateSaillie
.compareTo(a.dateSaillie),
);

return liste;
}
}