import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/local_business_cache_service.dart';
import '../models/veterinaire_model.dart';

class FirebaseVeterinaireRepository {
  FirebaseVeterinaireRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'veterinaires';
  final LocalBusinessCacheService _cache = LocalBusinessCacheService.instance;

  String _cacheKey(String bergerieId) => 'veterinaires_${bergerieId.trim()}';

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
    final id = bergerieId.trim();
    if (id.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('bergerieId', isEqualTo: id)
          .get(const GetOptions(source: Source.server));

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

      await _cache.saveList(
        _cacheKey(id),
        veterinaires
            .map((veterinaire) => {
                  'id': veterinaire.id,
                  ...veterinaire.toMap(),
                })
            .toList(),
      );

      return veterinaires;
    } catch (_) {
      final cached = await _cache.loadList(_cacheKey(id));
      if (cached == null) return [];

      final veterinaires = cached
          .map(
            (map) => VeterinaireModel.fromMap({
              ...map,
              'id': map['id']?.toString() ?? '',
            }),
          )
          .where((veterinaire) => veterinaire.bergerieId == id)
          .toList();

      veterinaires.sort(
        (a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()),
      );

      return veterinaires;
    }
  }
}