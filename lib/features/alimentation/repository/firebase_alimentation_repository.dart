import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/local_business_cache_service.dart';
import '../models/alimentation_model.dart';
import '../../../core/session/current_user_service.dart';

class FirebaseAlimentationRepository {
  FirebaseAlimentationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'alimentations';
  final LocalBusinessCacheService _cache = LocalBusinessCacheService.instance;

  String _cacheKey(String bergerieId) => 'alimentations_$bergerieId';

  Future<void> ajouter(AlimentationModel alimentation) async {
    final cached = await _cache.loadList(_cacheKey(alimentation.bergerieId)) ?? <Map<String, dynamic>>[];
    await _cache.saveList(
      _cacheKey(alimentation.bergerieId),
      [
        ...cached.where((item) => item['id']?.toString() != alimentation.id),
        {'id': alimentation.id, ...alimentation.toMap()},
      ],
    );
    unawaited(_synchroniserAjout(alimentation));
  }

  Future<void> modifier(AlimentationModel alimentation) async {
    if (alimentation.stockDeduit) {
      throw StateError(
        'Cette alimentation est déjà liée à une sortie de stock et ne peut plus être modifiée.',
      );
    }
    final cached = await _cache.loadList(_cacheKey(alimentation.bergerieId)) ?? <Map<String, dynamic>>[];
    await _cache.saveList(
      _cacheKey(alimentation.bergerieId),
      [
        ...cached.where((item) => item['id']?.toString() != alimentation.id),
        {'id': alimentation.id, ...alimentation.toMap()},
      ],
    );
    unawaited(_synchroniserModification(alimentation));
  }

  Future<void> supprimer(String id) async {
    final bergerieId = CurrentUserService.instance.bergerieId?.trim() ?? '';
    if (bergerieId.isNotEmpty) {
      final cached = await _cache.loadList(_cacheKey(bergerieId)) ?? <Map<String, dynamic>>[];
      await _cache.saveList(
        _cacheKey(bergerieId),
        cached.where((item) => item['id']?.toString() != id).toList(),
      );
    }
    unawaited(_synchroniserSuppression(id));
  }

  Future<void> _synchroniserAjout(AlimentationModel alimentation) async {
    try {
      await _firestore.collection(_collection).doc(alimentation.id).set(alimentation.toMap());
    } catch (_) {}
  }

  Future<void> _synchroniserModification(AlimentationModel alimentation) async {
    try {
      await _firestore.collection(_collection).doc(alimentation.id).set(alimentation.toMap());
    } catch (_) {}
  }

  Future<void> _synchroniserSuppression(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (_) {}
  }

  Future<List<AlimentationModel>> getParBergerie(String bergerieId) async {
    final id = bergerieId.trim();
    if (id.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('bergerieId', isEqualTo: id)
          .get();

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
