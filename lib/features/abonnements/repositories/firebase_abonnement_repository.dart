import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/abonnement_model.dart';

class FirebaseAbonnementRepository {
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

static const String _collection = 'abonnements';

CollectionReference<Map<String, dynamic>> get _abonnements =>
_firestore.collection(_collection);

Future<List<AbonnementModel>> getAbonnements() async {
final snapshot = await _abonnements
.orderBy('dateCreation', descending: true)
.get();

return snapshot.docs
.map(
(doc) => AbonnementModel.fromMap(
doc.data(),
doc.id,
),
)
.toList();
}

Future<AbonnementModel?> getAbonnementById(
String id,
) async {
final doc = await _abonnements.doc(id).get();

if (!doc.exists || doc.data() == null) {
return null;
}

return AbonnementModel.fromMap(
doc.data()!,
doc.id,
);
}

Future<void> addAbonnement(
AbonnementModel abonnement,
) async {
await _abonnements
.doc(abonnement.id)
.set(abonnement.toMap());
}

Future<void> updateAbonnement(
AbonnementModel abonnement,
) async {
await _abonnements
.doc(abonnement.id)
.update(abonnement.toMap());
}

Future<void> deleteAbonnement(
String id,
) async {
await _abonnements.doc(id).delete();
}

Stream<List<AbonnementModel>> watchAbonnements() {
return _abonnements
.orderBy('dateCreation', descending: true)
.snapshots()
.map(
(snapshot) => snapshot.docs
.map(
(doc) => AbonnementModel.fromMap(
doc.data(),
doc.id,
),
)
.toList(),
);
}

Future<bool> abonnementExiste(
String id,
) async {
final doc = await _abonnements.doc(id).get();
return doc.exists;
}

Future<int> getNombreAbonnements() async {
final snapshot = await _abonnements.get();
return snapshot.size;
}

Future<List<AbonnementModel>> rechercherAbonnements(
    String recherche,
    ) async {
  final abonnements = await getAbonnements();

  final filtre = recherche.toLowerCase().trim();

  return abonnements.where((abonnement) {
    return abonnement.numero.toLowerCase().contains(filtre) ||
        abonnement.clientNom.toLowerCase().contains(filtre) ||
        abonnement.bergerieNom.toLowerCase().contains(filtre) ||
        abonnement.pack.toLowerCase().contains(filtre) ||
        abonnement.statut.toLowerCase().contains(filtre);
  }).toList();
}

}