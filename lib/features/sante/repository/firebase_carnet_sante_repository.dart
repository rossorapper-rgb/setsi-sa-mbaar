import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/carnet_sante_model.dart';

class FirebaseCarnetSanteRepository {
  FirebaseCarnetSanteRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'carnet_sante';

  Future<void> ajouter(CarnetSanteModel soin) async {
    await _firestore.collection(_collection).doc(soin.id).set(soin.toMap());
  }

  Future<void> modifier(CarnetSanteModel soin) async {
    await _firestore.collection(_collection).doc(soin.id).update(soin.toMap());
  }

  Future<void> supprimer(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<List<CarnetSanteModel>> getParBergerie(String bergerieId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('bergerieId', isEqualTo: bergerieId)
        .get();

    final result = snapshot.docs
        .map((doc) => CarnetSanteModel.fromMap({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  Future<List<CarnetSanteModel>> getParMouton(String moutonId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('moutonId', isEqualTo: moutonId)
        .get();

    final result = snapshot.docs
        .map((doc) => CarnetSanteModel.fromMap({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }
}
