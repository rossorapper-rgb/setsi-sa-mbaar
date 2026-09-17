import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/alimentation_model.dart';

class FirebaseAlimentationRepository {
  FirebaseAlimentationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'alimentations';

  Future<void> ajouter(AlimentationModel alimentation) async {
    await _firestore
        .collection(_collection)
        .doc(alimentation.id)
        .set(alimentation.toMap());
  }

  Future<void> modifier(AlimentationModel alimentation) async {
    await _firestore
        .collection(_collection)
        .doc(alimentation.id)
        .update(alimentation.toMap());
  }

  Future<void> supprimer(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<List<AlimentationModel>> getParBergerie(String bergerieId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('bergerieId', isEqualTo: bergerieId)
        .get();

    final result = snapshot.docs
        .map((doc) => AlimentationModel.fromMap({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }
}
