import 'dart:async';

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

      final snapshot = await query.get(
        const GetOptions(),
      );
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

  Future<void> addGestation(GestationModel gestation) async {
    final key = _cacheKey;
    if (key != null) {
      final cached = await _cache.loadList(key) ?? [];
      final updated = [
        ...cached.where((item) => item['id']?.toString() != gestation.id),
        {'id': gestation.id, ...gestation.toMap()},
      ];
      await _cache.saveList(key, updated);
    }

    // Firestore Web conserve l'écriture localement et la synchronise dès
    // que la connexion revient. On ne bloque pas l'interface sur le réseau.
    unawaited(
      _gestations.doc(gestation.id).set(gestation.toMap()),
    );
  }

  Future<void> updateGestation(GestationModel gestation) async {
    final key = _cacheKey;
    if (key != null) {
      final cached = await _cache.loadList(key) ?? [];
      final updated = [
        ...cached.where((item) => item['id']?.toString() != gestation.id),
        {'id': gestation.id, ...gestation.toMap()},
      ];
      await _cache.saveList(key, updated);
    }

    // Même comportement en modification : ne pas attendre le réseau.
    unawaited(
      _gestations.doc(gestation.id).set(gestation.toMap()),
    );
  }
  Future<GestationModel> enregistrerAgneauAjoute({
    required String gestationId,
    required String moutonId,
  }) async {
    final key = _cacheKey;
    final now = DateTime.now();

    if (key != null) {
      final cached = await _cache.loadList(key);
      if (cached != null) {
        final index = cached.indexWhere(
          (item) => item['id']?.toString() == gestationId,
        );
        if (index >= 0) {
          final current = Map<String, dynamic>.from(cached[index]);
          final ids = ((current['agneauMoutonIds'] as List?) ?? const [])
              .map((e) => e.toString())
              .toSet();
          ids.add(moutonId);
          current['agneauMoutonIds'] = ids.toList();
          current['dateModification'] = Timestamp.fromDate(now);
          final updated = [...cached];
          updated[index] = current;
          await _cache.saveList(key, updated);

          unawaited(_gestations.doc(gestationId).update({
            'agneauMoutonIds': ids.toList(),
            'dateModification': Timestamp.fromDate(now),
          }));
          return GestationModel.fromMap(current, gestationId);
        }
      }
    }

    final doc = await _gestations.doc(gestationId).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('Naissance introuvable.');
    }

    final data = Map<String, dynamic>.from(doc.data()!);
    final ids = ((data['agneauMoutonIds'] as List?) ?? const [])
        .map((e) => e.toString())
        .toSet();
    ids.add(moutonId);
    data['agneauMoutonIds'] = ids.toList();
    data['dateModification'] = Timestamp.fromDate(now);

    if (key != null) {
      final cached = await _cache.loadList(key) ?? [];
      final updated = [
        ...cached.where((item) => item['id']?.toString() != gestationId),
        {'id': gestationId, ...data},
      ];
      await _cache.saveList(key, updated);
    }

    unawaited(_gestations.doc(gestationId).set(data));
    return GestationModel.fromMap(data, gestationId);
  }

  Future<void> deleteGestation(String id) async {
    final key = _cacheKey;
    if (key != null) {
      final cached = await _cache.loadList(key);
      if (cached != null) {
        final updated = cached
            .where((item) => item['id']?.toString() != id)
            .toList();
        await _cache.saveList(key, updated);
      }
    }

    // La suppression locale est immédiate. Firestore synchronisera
    // la suppression dès que la connexion est disponible.
    unawaited(_gestations.doc(id).delete());
  }

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
    final id = bergerieId.trim();
    if (id.isEmpty) return [];
    if (!_isAdmin && _bergerieIdSession != id) return [];

    try {
      final snapshot = await _gestations
          .where('bergerieId', isEqualTo: id)
          .get(const GetOptions());

      final result = snapshot.docs
          .map((doc) => GestationModel.fromMap(doc.data(), doc.id))
          .toList();

      result.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));

      await _cache.saveList(
        'gestations_$id',
        result
            .map((gestation) => {
                  'id': gestation.id,
                  ...gestation.toMap(),
                })
            .toList(),
      );

      return result;
    } catch (_) {
      final cached = await _cache.loadList('gestations_$id');
      if (cached == null) return [];

      final result = cached
          .map(
            (map) => GestationModel.fromMap(
              map,
              map['id']?.toString() ?? '',
            ),
          )
          .where((gestation) => gestation.bergerieId == id)
          .toList();

      result.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
      return result;
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

  Future<GestationModel> enregistrerMiseBas({
    required String gestationId,
    required DateTime dateMiseBas,
    required int nombreAgneaux,
    required int nombreMales,
    required int nombreFemelles,
    required int nombreMortNes,
    String observations = '',
    String? photoUrl,
  }) async {
    final dateModification = DateTime.now();
    final key = _cacheKey;

    if (key != null) {
      final cached = await _cache.loadList(key);
      if (cached != null) {
        final index = cached.indexWhere(
          (item) => item['id']?.toString() == gestationId,
        );

        if (index >= 0) {
          final current = Map<String, dynamic>.from(cached[index]);
          current['id'] = gestationId;
          current['statut'] = 'Terminée';
          current['dateMiseBas'] = Timestamp.fromDate(dateMiseBas);
          current['nombreAgneaux'] = nombreAgneaux;
          current['nombreMales'] = nombreMales;
          current['nombreFemelles'] = nombreFemelles;
          current['nombreMortNes'] = nombreMortNes;
          current['observations'] = observations;
          if (photoUrl != null) current['photoUrl'] = photoUrl;
          current['active'] = false;
          current['dateModification'] =
              Timestamp.fromDate(dateModification);

          final updated = [...cached];
          updated[index] = current;
          await _cache.saveList(key, updated);

          final model = GestationModel.fromMap(current, gestationId);

          unawaited(
            _gestations.doc(gestationId).update({
              'statut': 'Terminée',
              'dateMiseBas': Timestamp.fromDate(dateMiseBas),
              'nombreAgneaux': nombreAgneaux,
              'nombreMales': nombreMales,
              'nombreFemelles': nombreFemelles,
              'nombreMortNes': nombreMortNes,
              'observations': observations,
              'photoUrl': photoUrl,
              'active': false,
              'dateModification': Timestamp.fromDate(dateModification),
            }),
          );

          return model;
        }
      }
    }

    final actuelle = await _gestations.doc(gestationId).get();
    if (!actuelle.exists || actuelle.data() == null) {
      throw StateError('Gestation introuvable après mise à jour.');
    }

    final data = {
      ...actuelle.data()!,
      'statut': 'Terminée',
      'dateMiseBas': Timestamp.fromDate(dateMiseBas),
      'nombreAgneaux': nombreAgneaux,
      'nombreMales': nombreMales,
      'nombreFemelles': nombreFemelles,
      'nombreMortNes': nombreMortNes,
      'observations': observations,
      'photoUrl': photoUrl,
      'active': false,
      'dateModification': Timestamp.fromDate(dateModification),
      'id': gestationId,
    };

    await _cache.saveList(
      key ?? 'gestations_' + data['bergerieId'].toString(),
      [data],
    );

    unawaited(_gestations.doc(gestationId).update(data));
    return GestationModel.fromMap(data, gestationId);
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
