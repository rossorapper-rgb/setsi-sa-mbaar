import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/session/current_user_service.dart';
import '../../../core/session/local_business_cache_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/mouton_model.dart';

class FirebaseMoutonRepository {
  FirebaseMoutonRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'moutons';
  final LocalBusinessCacheService _cache = LocalBusinessCacheService.instance;

  String _cacheKey(String bergerieId) => 'moutons_$bergerieId';

  /// Ajouter un mouton
  Future<void> addMouton(MoutonModel mouton) async {
    await _firestore
        .collection(_collection)
        .doc(mouton.id)
        .set(mouton.toMap());
  }

  /// Modifier un mouton
  Future<void> updateMouton(MoutonModel mouton) async {
    await _firestore
        .collection(_collection)
        .doc(mouton.id)
        .update(mouton.toMap());
  }

  /// Archiver un mouton
  Future<void> archiveMouton(String id) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .update({'actif': false});
  }

  /// Tous les moutons actifs de la bergerie de l'utilisateur.
  /// L'administrateur peut voir tous les moutons actifs.
  Future<List<MoutonModel>> getMoutons() async {
    final utilisateur = CurrentUserService.instance.currentUser;

    if (AuthService.instance.isAdmin) {
      return _getMoutonsFromQuery(
        _firestore
            .collection(_collection)
            .where('actif', isEqualTo: true),
      );
    }

    final bergerieId = utilisateur?.bergerieId;

    if (bergerieId == null || bergerieId.trim().isEmpty) {
      return [];
    }

    return getMoutonsByBergerie(bergerieId);
  }

  Future<List<MoutonModel>> _getMoutonsFromQuery(
    Query<Map<String, dynamic>> query, {
    bool forceServer = false,
  }) async {
    final snapshot = await query.get(
      forceServer
          ? const GetOptions(source: Source.server)
          : const GetOptions(),
    );

    final moutons = snapshot.docs
        .map(
          (doc) => MoutonModel.fromMap({
            ...doc.data(),
            'id': doc.id,
          }),
        )
        .toList();

    moutons.sort(
      (a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()),
    );

    final bergerieId = CurrentUserService.instance.bergerieId?.trim();
    if (bergerieId != null && bergerieId.isNotEmpty) {
      await _cache.saveList(
        _cacheKey(bergerieId),
        moutons.map((mouton) => mouton.toMap()).toList(),
      );
    }

    return moutons;
  }

  Future<List<MoutonModel>> _loadCachedMoutons(String bergerieId) async {
    final cached = await _cache.loadList(_cacheKey(bergerieId));
    if (cached == null) {
      return [];
    }

    final moutons = cached
        .map(MoutonModel.fromMap)
        .where((mouton) => mouton.actif)
        .toList();

    moutons.sort(
      (a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()),
    );

    return moutons;
  }

  /// Un mouton par son id
  Future<MoutonModel?> getMoutonById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return MoutonModel.fromMap({
      ...doc.data()!,
      'id': doc.id,
    });
  }

  /// Tous les moutons d'une bergerie
  Future<List<MoutonModel>> getMoutonsByBergerie(String bergerieId) async {
    final id = bergerieId.trim();
    if (id.isEmpty) {
      return [];
    }

    try {
      return await _getMoutonsFromQuery(
        _firestore
            .collection(_collection)
            .where('bergerieId', isEqualTo: id)
            .where('actif', isEqualTo: true),
      );
    } catch (_) {
      return _loadCachedMoutons(id);
    }
  }

  /// Tous les moutons d'un client.
  /// La bergerie n'est pas obligatoire.
  Future<List<MoutonModel>> getMoutonsByClient(String clientId) async {
    if (clientId.trim().isEmpty) {
      return [];
    }

    return _getMoutonsFromQuery(
      _firestore
          .collection(_collection)
          .where('clientId', isEqualTo: clientId)
          .where('actif', isEqualTo: true),
    );
  }

  /// Moutons du client qui ne sont rattachés à aucune bergerie.
  Future<List<MoutonModel>> getMoutonsSansBergerie(String clientId) async {
    final moutons = await getMoutonsByClient(clientId);

    return moutons
        .where((mouton) => mouton.bergerieId.trim().isEmpty)
        .toList();
  }

  /// Nombre de moutons d'une bergerie
  Future<int> getNombreMoutons(String bergerieId) async {
    if (bergerieId.trim().isEmpty) {
      return 0;
    }

    final snapshot = await _firestore
        .collection(_collection)
        .where('bergerieId', isEqualTo: bergerieId)
        .where('actif', isEqualTo: true)
        .get();

    return snapshot.docs.length;
  }

  /// Tous les béliers actifs de la bergerie de l'utilisateur.
  Future<List<MoutonModel>> getBeliers() async {
    final moutons = await getMoutons();

    return moutons.where((m) {
      final sexe = m.sexe.toLowerCase();
      return sexe == 'male' || sexe == 'mâle';
    }).toList();
  }

  /// Toutes les brebis actives de la bergerie de l'utilisateur.
  Future<List<MoutonModel>> getBrebis() async {
    final moutons = await getMoutons();

    return moutons.where((m) {
      return m.sexe.toLowerCase() == 'femelle';
    }).toList();
  }

  /// Toutes les brebis d'une bergerie
  Future<List<MoutonModel>> getBrebisByBergerie(String bergerieId) async {
    final moutons = await getMoutonsByBergerie(bergerieId);

    return moutons.where((m) {
      return m.sexe.toLowerCase() == 'femelle';
    }).toList();
  }

  /// Tous les béliers d'une bergerie
  Future<List<MoutonModel>> getBeliersByBergerie(String bergerieId) async {
    final moutons = await getMoutonsByBergerie(bergerieId);

    return moutons.where((m) {
      final sexe = m.sexe.toLowerCase();
      return sexe == 'male' || sexe == 'mâle';
    }).toList();
  }

  /// Supprimer (archiver) un mouton
  Future<void> deleteMouton(String id) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .update({'actif': false});
  }
}
