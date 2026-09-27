import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/current_user_service.dart';
import '../../../core/session/local_business_cache_service.dart';
import '../../alimentation/models/alimentation_model.dart';
import '../../alimentation/repository/firebase_alimentation_repository.dart';
import '../models/finance_entry_model.dart';

class FirebaseFinanceRepository {
  FirebaseFinanceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final LocalBusinessCacheService _cache =
      LocalBusinessCacheService.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('finance_entries');

  String get _bergerieId {
    final id = CurrentUserService.instance.bergerieId?.trim();
    if (id == null || id.isEmpty) {
      throw StateError('Aucune bergerie associée à cet utilisateur.');
    }
    return id;
  }

  String _cacheKey(String bergerieId) => 'finances_$bergerieId';

  Future<List<FinanceEntryModel>> getEntries() async {
    final bergerieId = _bergerieId;

    try {
      final snapshot = await _collection
          .where('bergerieId', isEqualTo: bergerieId)
          .get();

      final entries = snapshot.docs
          .map(
            (doc) => FinanceEntryModel.fromMap({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();

      entries.sort((a, b) => b.date.compareTo(a.date));

      await _cache.saveList(
        _cacheKey(bergerieId),
        entries
            .map(
              (entry) => {
                'id': entry.id,
                ...entry.toMap(),
              },
            )
            .toList(),
      );

      return entries;
    } catch (_) {
      final cached = await _cache.loadList(_cacheKey(bergerieId));
      if (cached == null) return [];

      final entries = cached.map(FinanceEntryModel.fromMap).toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    }
  }

  Future<FinanceEntryModel> ajouter({
    required FinanceEntryType type,
    required String libelle,
    String categorie = '',
    required double montant,
    required DateTime date,
    String observation = '',
  }) async {
    final doc = _collection.doc();
    final entry = FinanceEntryModel(
      id: doc.id,
      bergerieId: _bergerieId,
      type: type,
      libelle: libelle.trim(),
      categorie: categorie.trim(),
      montant: montant,
      date: date,
      observation: observation.trim(),
    );
    final cached = await _cache.loadList(_cacheKey(entry.bergerieId)) ?? <Map<String, dynamic>>[];
    final updated = [
      ...cached.where((item) => item['id']?.toString() != entry.id),
      {'id': entry.id, ...entry.toMap()},
    ];
    await _cache.saveList(_cacheKey(entry.bergerieId), updated);

    unawaited(_synchroniserAjout(doc, entry));
    return entry;
  }

  Future<void> modifier(FinanceEntryModel entry) async {
    if (entry.bergerieId != _bergerieId) {
      throw StateError('Cette opération n’appartient pas à votre bergerie.');
    }
    final cached = await _cache.loadList(_cacheKey(entry.bergerieId)) ?? <Map<String, dynamic>>[];
    final updated = [
      ...cached.where((item) => item['id']?.toString() != entry.id),
      {'id': entry.id, ...entry.toMap()},
    ];
    await _cache.saveList(_cacheKey(entry.bergerieId), updated);

    unawaited(_synchroniserModification(entry));
  }

  Future<void> supprimer(String id) async {
    final bergerieId = _bergerieId;
    final cached = await _cache.loadList(_cacheKey(bergerieId)) ?? <Map<String, dynamic>>[];
    final cachedEntry = cached.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['id']?.toString() == id,
      orElse: () => null,
    );
    if (cachedEntry != null) {
      final entry = FinanceEntryModel.fromMap(cachedEntry);
      if (entry.bergerieId != bergerieId) {
        throw StateError('Cette opération n’appartient pas à votre bergerie.');
      }
    }
    await _cache.saveList(
      _cacheKey(bergerieId),
      cached.where((item) => item['id']?.toString() != id).toList(),
    );
    unawaited(_synchroniserSuppression(id));
  }


  Future<void> _synchroniserAjout(
    DocumentReference<Map<String, dynamic>> doc,
    FinanceEntryModel entry,
  ) async {
    try {
      await doc.set(entry.toMap());
    } catch (_) {
      // La donnée locale reste disponible hors ligne.
    }
  }

  Future<void> _synchroniserModification(FinanceEntryModel entry) async {
    try {
      await _collection.doc(entry.id).set(entry.toMap());
    } catch (_) {
      // La modification locale reste disponible hors ligne.
    }
  }

  Future<void> _synchroniserSuppression(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (_) {
      // La suppression locale reste disponible hors ligne.
    }
  }

  Future<List<AlimentationModel>> getAlimentations() async {
    return FirebaseAlimentationRepository().getParBergerie(_bergerieId);
  }
}
