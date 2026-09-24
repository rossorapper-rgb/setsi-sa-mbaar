import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/current_user_service.dart';
import '../../../core/session/local_business_cache_service.dart';
import '../models/gestation_model.dart';

class FirebaseGestationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'gestations';
  static const String _statutGestante = 'Gestante';
  final LocalBusinessCacheService _cache = LocalBusinessCacheService.instance;

  String? get _cacheKey {
    final id = _bergerieIdSession;
    return id == null ? null : 'gestations_$id';
  }

  CollectionReference<Map<String, dynamic>> get _gestations => _firestore.collection(_collection);

  String? get _bergerieIdSession {
    final id = CurrentUserService.instance.bergerieId?.trim();
    return (id == null || id.isEmpty) ? null : id;
  }

  bool get _isAdmin => CurrentUserService.instance.isAdmin;

  Future<List<GestationModel>> getGestations() async {
    try {
      Query<Map<String, dynamic>> query = _gestations;
      if (!_isAdmin) {
        final bergerieId = _bergerieIdSession;
        if (bergerieId == null) return [];
        query = query.where('bergerieId', isEqualTo: bergerieId);
      }

      final snapshot = await query.get();
      final result = snapshot.docs
          .map((doc) => GestationModel.fromMap(doc.data(), doc.id))
          .toList();

      result.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));

      final key = _cacheKey;
      if (key != null) {
        await _cache.saveList(
          key,
          result.map((gestation) => {
            'id': gestation.id,
            ...gestation.toMap(),
          }).toList(),
        );
      }

      return result;
    } catch (_) {
      final key = _cacheKey;
      if (key == null) return [];

      final cached = await _cache.loadList(key);
      if (cached == null) return [];

      final result = cached
          .map((map) => GestationModel.fromMap(
                map,
                map['id']?.toString() ?? '',
              ))
          .where((gestation) =>
              _isAdmin || gestation.bergerieId == _bergerieIdSession)
          .toList();

      result.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
      return result;
    }
  }

  Stream<List<GestationModel>> watchGestations() {
    Query<Map<String, dynamic>> query = _gestations;
    if (!_isAdmin) {
      final bergerieId = _bergerieIdSession;
      if (bergerieId == null) return Stream.value([]);
      query = query.where('bergerieId', isEqualTo: bergerieId);
    }
    return query.snapshots().map((snapshot) {
      final result = snapshot.docs.map((doc) => GestationModel.fromMap(doc.data(), doc.id)).toList();
      result.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
      return result;
    });
  }

  Future<GestationModel?> getGestationById(String id) async {
    final doc = await _gestations.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    final gestation = GestationModel.fromMap(doc.data()!, doc.id);
    if (!_isAdmin && gestation.bergerieId != _bergerieIdSession) return null;
    return gestation;
  }

  Future<GestationModel?> getGestationActiveByBrebis(String brebisId) async {
    Query<Map<String, dynamic>> query = _gestations.where('brebisId', isEqualTo: brebisId).where('statut', isEqualTo: _statutGestante);
    if (!_isAdmin) {
      final bergerieId = _bergerieIdSession;
      if (bergerieId == null) return null;
      query = query.where('bergerieId', isEqualTo: bergerieId);
    }
    final snapshot = await query.limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return GestationModel.fromMap(doc.data(), doc.id);
  }

  Future<void> addGestation(GestationModel gestation) async => _gestations.doc(gestation.id).set(gestation.toMap());
  Future<void> updateGestation(GestationModel gestation) async => _gestations.doc(gestation.id).update(gestation.toMap());
  Future<void> deleteGestation(String id) async => _gestations.doc(id).delete();

  Future<List<GestationModel>> getGestationsByMouton(String brebisId) async {
    Query<Map<String, dynamic>> query = _gestations.where('brebisId', isEqualTo: brebisId);
    if (!_isAdmin) {
      final bergerieId = _bergerieIdSession;
      if (bergerieId == null) return [];
      query = query.where('bergerieId', isEqualTo: bergerieId);
    }
    final snapshot = await query.get();
    final result = snapshot.docs.map((doc) => GestationModel.fromMap(doc.data(), doc.id)).toList();
    result.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
    return result;
  }

  Future<List<GestationModel>> getGestationsEnCours() async {
    final gestations = await getGestations();
    return gestations.where((gestation) => gestation.statut == _statutGestante).toList();
  }

  Future<List<GestationModel>> getGestationsParBergerie(String bergerieId) async {
    if (!_isAdmin && _bergerieIdSession != bergerieId) return [];
    try {
      final snapshot = await _gestations.where('bergerieId', isEqualTo: bergerieId).get();
      final result = snapshot.docs.map((doc) => GestationModel.fromMap(doc.data(), doc.id)).toList();
      result.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
      return result;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<GestationModel>> getGestationsActives() async => getGestationsEnCours();
  Future<int> getNombreGestations() async => (!_isAdmin && _bergerieIdSession == null) ? 0 : (await getGestations()).length;
  Future<int> getNombreGestationsEnCours() async => (await getGestationsEnCours()).length;

  Future<int> getNombreGestationsTerminees() async {
    Query<Map<String, dynamic>> query = _gestations.where('statut', isEqualTo: 'Terminée');
    if (!_isAdmin) {
      final bergerieId = _bergerieIdSession;
      if (bergerieId == null) return 0;
      query = query.where('bergerieId', isEqualTo: bergerieId);
    }
    return (await query.get()).size;
  }

  Future<List<GestationModel>> rechercherGestations(String recherche) async {
    final liste = await getGestations();
    final filtre = recherche.trim().toLowerCase();
    return liste.where((g) => g.nomFemelle.toLowerCase().contains(filtre) || g.belierNom.toLowerCase().contains(filtre) || g.statut.toLowerCase().contains(filtre)).toList();
  }

  Future<void> annulerGestation(String id) async => _gestations.doc(id).update({'statut': 'Annulée', 'active': false, 'dateModification': Timestamp.fromDate(DateTime.now())});
  Future<void> reactiverGestation(String id) async => _gestations.doc(id).update({'statut': _statutGestante, 'active': true, 'dateModification': Timestamp.fromDate(DateTime.now())});

  Future<void> terminerGestation({required String id, required DateTime dateMiseBas, required int nombrePetits, required int males, required int femelles}) async {
    await _gestations.doc(id).update({
      'statut': 'Terminée',
      'dateMiseBas': Timestamp.fromDate(dateMiseBas),
      'nombreAgneaux': nombrePetits,
      'nombreMales': males,
      'nombreFemelles': femelles,
      'active': false,
      'dateModification': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> enregistrerMiseBas({
    required String gestationId,
    required DateTime dateMiseBas,
    required int nombreAgneaux,
    required int nombreMales,
    required int nombreFemelles,
    required int nombreMortNes,
    String observations = '',
    String? photoUrl,
  }) async {
    await _gestations.doc(gestationId).update({
      'statut': 'Terminée',
      'dateMiseBas': Timestamp.fromDate(dateMiseBas),
      'nombreAgneaux': nombreAgneaux,
      'nombreMales': nombreMales,
      'nombreFemelles': nombreFemelles,
      'nombreMortNes': nombreMortNes,
      'observations': observations,
      'photoUrl': photoUrl,
      'active': false,
      'dateModification': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> mettreAJourStatut({required String gestationId, required String statut}) async => _gestations.doc(gestationId).update({'statut': statut, 'dateModification': Timestamp.fromDate(DateTime.now())});
  Future<void> cloturerGestation(String gestationId) async => _gestations.doc(gestationId).update({'statut': 'Terminée', 'active': false, 'dateModification': Timestamp.fromDate(DateTime.now())});

  Future<int> getNombreGestationsEnRetard() async {
    final liste = await getGestationsEnCours();
    return liste.where((g) => g.estEnRetard).length;
  }

  Future<int> getNombreMisesBasProchaines() async {
    final liste = await getGestationsEnCours();
    return liste.where((g) => g.joursRestants >= 0 && g.joursRestants <= 15).length;
  }
}
