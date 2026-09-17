import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/veterinaire_model.dart';

class FirebaseVeterinaireRepository {
  FirebaseVeterinaireRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'veterinaires';

  Future<void> addVeterinaire(VeterinaireModel veterinaire) async {
    await _firestore
        .collection(_collection)
        .doc(veterinaire.id)
        .set(veterinaire.toMap());
  }

  Future<void> updateVeterinaire(VeterinaireModel veterinaire) async {
    await _firestore
        .collection(_collection)
        .doc(veterinaire.id)
        .update(veterinaire.toMap());
  }

  Future<void> deleteVeterinaire(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<List<VeterinaireModel>> getVeterinairesParBergerie(
    String bergerieId,
  ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('bergerieId', isEqualTo: bergerieId)
        .get();

    final veterinaires = snapshot.docs
        .map(
          (doc) => VeterinaireModel.fromMap({
            ...doc.data(),
            'id': doc.id,
          }),
        )
        .toList();

    veterinaires.sort(
      (a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()),
    );

    return veterinaires;
  }
}