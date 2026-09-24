import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/local_business_cache_service.dart';
import '../models/carnet_sante_model.dart';

class FirebaseCarnetSanteRepository {
  FirebaseCarnetSanteRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'carnet_sante';
  final LocalBusinessCacheService _cache = LocalBusinessCacheService.instance;

  String _cacheKey(String bergerieId) => 'carnet_sante_$bergerieId';

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
    final id = bergerieId.trim();
    if (id.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('bergerieId', isEqualTo: id)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 4));

      final result = snapshot.docs
          .map(
            (doc) => CarnetSanteModel.fromMap({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();

      result.sort((a, b) => b.date.compareTo(a.date));

      try {
        await _cache.saveList(
          _cacheKey(id),
          result
              .map(
                (soin) => {
                  'id': soin.id,
                  ...soin.toMap(),
                },
              )
              .toList(),
        );
      } catch (_) {}

      return result;
    } catch (_) {
      return _loadCachedParBergerie(id);
    }
  }

  Future<List<CarnetSanteModel>> _loadCachedParBergerie(
    String bergerieId,
  ) async {
    final cached = await _cache.loadList(_cacheKey(bergerieId));
    if (cached == null) return [];

    final result = cached
        .map(CarnetSanteModel.fromMap)
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
        .map(
          (doc) => CarnetSanteModel.fromMap({
            ...doc.data(),
            'id': doc.id,
          }),
        )
        .toList();

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }
}
