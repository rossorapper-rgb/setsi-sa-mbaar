import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/current_user_service.dart';
import '../../../core/session/local_business_cache_service.dart';
import '../models/intervention_model.dart';

class FirebaseInterventionRepository {
  FirebaseInterventionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final LocalBusinessCacheService _cache = LocalBusinessCacheService.instance;

  String _cacheKey(String bergerieId) => 'interventions_${bergerieId.trim()}';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('interventions');

  Future<InterventionModel> ajouter({
    required String type,
    required DateTime date,
    String? moutonId,
    String? moutonNom,
    String observation = '',
  }) async {
    final bergerieId = CurrentUserService.instance.bergerieId?.trim();
    if (bergerieId == null || bergerieId.isEmpty) {
      throw StateError('Aucune bergerie associée à cet utilisateur.');
    }

    final doc = _collection.doc();
    final intervention = InterventionModel(
      id: doc.id,
      bergerieId: bergerieId,
      type: type.trim(),
      date: date,
      moutonId: moutonId,
      moutonNom: moutonNom,
      observation: observation.trim(),
    );

    final key = _cacheKey(bergerieId);
    final cached = await _cache.loadList(key) ?? [];
    final updated = [
      ...cached.where((item) => item['id']?.toString() != intervention.id),
      {'id': intervention.id, ...intervention.toMap()},
    ];
    await _cache.saveList(key, updated);

    unawaited(_syncAdd(intervention));
    return intervention;
  }

  Future<void> modifier(InterventionModel intervention) async {
    final bergerieId = CurrentUserService.instance.bergerieId?.trim();
    if (bergerieId == null || bergerieId.isEmpty) {
      throw StateError('Aucune bergerie associée à cet utilisateur.');
    }
    if (intervention.bergerieId != bergerieId) {
      throw StateError('Cette intervention n’appartient pas à votre bergerie.');
    }
    if (intervention.stockDeduit) {
      throw StateError(
        'Cette intervention est déjà liée à une sortie de stock et ne peut plus être modifiée.',
      );
    }

    final key = _cacheKey(bergerieId);
    final cached = await _cache.loadList(key) ?? [];
    final updated = [
      ...cached.where((item) => item['id']?.toString() != intervention.id),
      {'id': intervention.id, ...intervention.toMap()},
    ];
    await _cache.saveList(key, updated);

    unawaited(_syncUpdate(intervention));
  }

  Future<void> supprimer(String id) async {
    final bergerieId = CurrentUserService.instance.bergerieId?.trim();
    if (bergerieId == null || bergerieId.isEmpty) {
      throw StateError('Aucune bergerie associée à cet utilisateur.');
    }

    final key = _cacheKey(bergerieId);
    final cached = await _cache.loadList(key);
    InterventionModel? intervention;

    if (cached != null) {
      for (final item in cached) {
        if (item['id']?.toString() == id) {
          intervention = InterventionModel.fromMap(item);
          break;
        }
      }
    }

    if (intervention == null) {
      try {
        final doc = await _collection.doc(id).get();
        if (!doc.exists) return;
        intervention = InterventionModel.fromMap({
          ...doc.data()!,
          'id': doc.id,
        });
      } catch (_) {
        throw StateError(
          'Cette intervention n’est pas disponible hors connexion.',
        );
      }
    }

    if (intervention.bergerieId != bergerieId) {
      throw StateError('Cette intervention n’appartient pas à votre bergerie.');
    }
    if (intervention.stockDeduit) {
      throw StateError(
        'Cette intervention est déjà liée à une sortie de stock et ne peut pas être supprimée.',
      );
    }

    if (cached != null) {
      await _cache.saveList(
        key,
        cached.where((item) => item['id']?.toString() != id).toList(),
      );
    }

    unawaited(_syncDelete(id));
  }

  Future<List<InterventionModel>> getToutesLesInterventions() async {
    final user = CurrentUserService.instance.currentUser;
    if (user == null) return [];

    final bergerieId = user.bergerieId?.trim();
    if (bergerieId == null || bergerieId.isEmpty) return [];

    return getParBergerie(bergerieId);
  }

  Future<List<InterventionModel>> getParBergerie(String bergerieId) async {
    final id = bergerieId.trim();
    if (id.isEmpty) return [];

    try {
      final snapshot = await _collection
          .where('bergerieId', isEqualTo: id)
          .get();

      final liste = snapshot.docs
          .map(
            (doc) => InterventionModel.fromMap({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();

      liste.sort((a, b) => b.date.compareTo(a.date));

      // Sur le Web, une lecture "server" peut parfois retourner une liste
      // vide lorsque la connexion est coupée sans lever d'exception.
      // Dans ce cas, ne remplaçons pas un cache existant par une liste vide.
      if (liste.isEmpty) {
        final cached = await _cache.loadList(_cacheKey(id));
        if (cached != null && cached.isNotEmpty) {
          final cachedListe = cached
              .map(InterventionModel.fromMap)
              .where((intervention) => intervention.bergerieId == id)
              .toList();
          cachedListe.sort((a, b) => b.date.compareTo(a.date));
          if (cachedListe.isNotEmpty) return cachedListe;
        }
      }

      // Conserver les données Firestore brutes dans le cache afin de
      // ne perdre aucun champ lors de la sérialisation hors ligne.
      await _cache.saveList(
        _cacheKey(id),
        snapshot.docs
            .map(
              (doc) => {
                ...doc.data(),
                'id': doc.id,
              },
            )
            .toList(),
      );

      return liste;
    } catch (_) {
      final cached = await _cache.loadList(_cacheKey(id));
      if (cached == null) return [];

      final liste = cached
          .map(InterventionModel.fromMap)
          .where((intervention) => intervention.bergerieId == id)
          .toList();

      liste.sort((a, b) => b.date.compareTo(a.date));
      return liste;
    }
  }

  Future<void> _syncAdd(InterventionModel intervention) async {
    try {
      await _collection.doc(intervention.id).set(intervention.toMap());
    } catch (_) {}
  }

  Future<void> _syncUpdate(InterventionModel intervention) async {
    try {
      await _collection.doc(intervention.id).set(intervention.toMap());
    } catch (_) {}
  }

  Future<void> _syncDelete(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (_) {}
  }

  // Compatibilite avec le dashboard admin historique.
  Future<List<InterventionModel>> getInterventionsDuClient(String clientId) async {
    final snapshot = await _collection
        .where('clientId', isEqualTo: clientId)
        .get();

    final liste = snapshot.docs
        .map((doc) => InterventionModel.fromMap(doc.data()))
        .toList();

    liste.sort((a, b) => b.date.compareTo(a.date));
    return liste;
  }

  Future<List<InterventionModel>> refresh() => getToutesLesInterventions();
}
