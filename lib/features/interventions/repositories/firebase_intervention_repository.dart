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

    await doc.set(intervention.toMap());
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

    await _collection.doc(intervention.id).update(intervention.toMap());
  }

  Future<void> supprimer(String id) async {
    final bergerieId = CurrentUserService.instance.bergerieId?.trim();
    if (bergerieId == null || bergerieId.isEmpty) {
      throw StateError('Aucune bergerie associée à cet utilisateur.');
    }

    final doc = await _collection.doc(id).get();
    if (!doc.exists) return;

    final intervention = InterventionModel.fromMap(doc.data()!);
    if (intervention.bergerieId != bergerieId) {
      throw StateError('Cette intervention n’appartient pas à votre bergerie.');
    }

    await _collection.doc(id).delete();
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
          .get(const GetOptions(source: Source.server));

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

      await _cache.saveList(
        _cacheKey(id),
        liste.map((intervention) => intervention.toMap()).toList(),
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
