import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/local_business_cache_service.dart';
import '../models/alimentation_model.dart';

class FirebaseAlimentationRepository {
  FirebaseAlimentationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'alimentations';
  final LocalBusinessCacheService _cache = LocalBusinessCacheService.instance;

  String _cacheKey(String bergerieId) => 'alimentations_$bergerieId';

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
    final id = bergerieId.trim();
    if (id.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('bergerieId', isEqualTo: id)
          .get(const GetOptions(source: Source.server));

      final result = snapshot.docs
          .map(
            (doc) => AlimentationModel.fromMap({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();

      result.sort((a, b) => b.date.compareTo(a.date));

      await _cache.saveList(
        _cacheKey(id),
        result
            .map(
              (item) => {
                'id': item.id,
                ...item.toMap(),
              },
            )
            .toList(),
      );

      return result;
    } catch (_) {
      final cached = await _cache.loadList(_cacheKey(id));
      if (cached == null) return [];

      final result = cached.map(AlimentationModel.fromMap).toList();
      result.sort((a, b) => b.date.compareTo(a.date));
      return result;
    }
  }
}
