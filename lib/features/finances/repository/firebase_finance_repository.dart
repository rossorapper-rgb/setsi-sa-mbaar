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
          .get(const GetOptions(source: Source.server));

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
      montant: montant,
      date: date,
      observation: observation.trim(),
    );
    await doc.set(entry.toMap());
    return entry;
  }

  Future<void> modifier(FinanceEntryModel entry) async {
    if (entry.bergerieId != _bergerieId) {
      throw StateError('Cette opération n’appartient pas à votre bergerie.');
    }
    await _collection.doc(entry.id).update(entry.toMap());
  }

  Future<void> supprimer(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return;
    final entry = FinanceEntryModel.fromMap(doc.data()!);
    if (entry.bergerieId != _bergerieId) {
      throw StateError('Cette opération n’appartient pas à votre bergerie.');
    }
    await _collection.doc(id).delete();
  }

  Future<List<AlimentationModel>> getAlimentations() async {
    return FirebaseAlimentationRepository().getParBergerie(_bergerieId);
  }
}
