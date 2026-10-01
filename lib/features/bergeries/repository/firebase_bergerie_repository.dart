import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/session/current_user_service.dart';
import '../../../core/session/local_business_cache_service.dart';
import '../models/bergerie_model.dart';
import 'bergerie_repository.dart';

class FirebaseBergerieRepository implements BergerieRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final String _collection = 'bergeries';

  final LocalBusinessCacheService _cache =
      LocalBusinessCacheService.instance;

  static const String _allBergeriesCacheKey = 'all_bergeries';

  String _cacheKey(String id) => 'bergerie_$id';

  @override
  Future<void> addBergerie(
      BergerieModel bergerie,
      ) async {
    await _firestore
        .collection(_collection)
        .doc(bergerie.id)
        .set(bergerie.toMap());
  }

  @override
  Future<void> updateBergerie(
      BergerieModel bergerie,
      ) async {
    // Local-first : la modification est disponible immédiatement,
    // même si Firebase est momentanément inaccessible.
    try {
      await _cache.saveList(
        _cacheKey(bergerie.id),
        [bergerie.toMap()],
      );
    } catch (_) {}

    // Synchronisation Firebase en arrière-plan.
    unawaited(
      _firestore
          .collection(_collection)
          .doc(bergerie.id)
          .set(
            bergerie.toMap(),
            SetOptions(merge: true),
          )
          .catchError((_) {}),
    );

    // Met à jour aussi le cache global utilisé par la liste Admin.
    try {
      final cached = await _cache.loadList(_allBergeriesCacheKey);
      if (cached != null) {
        final updated = cached
            .map(
              (item) => item['id']?.toString() == bergerie.id
                  ? bergerie.toMap()
                  : item,
            )
            .toList();

        await _cache.saveList(
          _allBergeriesCacheKey,
          updated,
        );
      }
    } catch (_) {}
  }

  @override
  Future<void> archiveBergerie(
      String id,
      ) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .update({
      'active': false,
      'dateModification':
      DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<BergerieModel>> getAllBergeries() async {
    final currentUser =
        CurrentUserService.instance;

    // L'administrateur central peut consulter toutes les bergeries.
    if (currentUser.isAdmin) {
      final snapshot =
          await _firestore
              .collection(_collection)
              .get();

      final bergeries = snapshot.docs
          .map(
            (doc) => BergerieModel.fromMap({
          ...doc.data(),
          'id': doc.id,
        }),
      )
          .toList();

      // Migration automatique des anciennes bergeries : si une bergerie
      // existe sans configuration publique, on crée sa configuration
      // manquante lorsque l'administrateur ouvre la liste.
      unawaited(creerConfigsPubliquesManquantes(bergeries));

      return bergeries;
    }

    // Un responsable ou un technicien ne consulte que sa bergerie.
    final bergerieId = currentUser.bergerieId;

    if ((currentUser.isResponsable || currentUser.isTechnicien) &&
        bergerieId != null &&
        bergerieId.isNotEmpty) {
      final doc = await _firestore
          .collection(_collection)
          .doc(bergerieId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return [];
      }

      return [
        BergerieModel.fromMap({
          ...doc.data()!,
          'id': doc.id,
        }),
      ];
    }

    // Les autres profils ne doivent pas accéder à la liste générale.
    return [];
  }

  Future<void> creerConfigsPubliquesManquantes(
      List<BergerieModel> bergeries,
      ) async {
    // On traite chaque bergerie indépendamment. Cela évite qu'une erreur
    // sur une ancienne configuration empêche les autres migrations.
    for (final bergerie in bergeries) {
      try {
        final configRef = _firestore
            .collection('bergerie_public_config')
            .doc(bergerie.id);

        // On vérifie uniquement le document attendu au lieu de lire toute
        // la collection. La migration reste ainsi robuste même si les
        // règles ou l'indexation de la collection évoluent.
        final existing = await configRef.get();
        if (existing.exists) {
          continue;
        }

        await configRef.set({
          'bergerieId': bergerie.id,
          'nomBergerie': bergerie.nom,
          'nomApplication': bergerie.nom,
          'logo': null,
          'imageAccueil': null,
          'couleurPrimaire': 0xFF1597B7,
          'couleurSecondaire': 0xFFF59A00,
          'couleurFond': 0xFFFFFFFF,
          'slogan': 'Une meilleure gestion pour une meilleure bergerie',
          'active': bergerie.active,
        });

        debugPrint(
          'CONFIG PUBLIQUE CRÉÉE : ' + bergerie.nom + ' (' + bergerie.id + ')',
        );
      } catch (e, stackTrace) {
        // La migration ne doit jamais bloquer l'affichage de la liste Admin,
        // mais l'erreur doit être visible pour pouvoir corriger la cause.
        debugPrint(
          'ERREUR CONFIG PUBLIQUE [' + bergerie.nom + ' / ' + bergerie.id + '] : ' + e.toString(),
        );
        debugPrintStack(
          stackTrace: stackTrace,
          label: 'STACK TRACE CONFIG PUBLIQUE',
        );
      }
    }
  }
  @override
  Future<BergerieModel?> getBergerieById(
      String id,
      ) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      return null;
    }

    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(trimmedId)
          .get(const GetOptions());

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final bergerie = BergerieModel.fromMap({
        ...doc.data()!,
        'id': doc.id,
      });

      try {
        await _cache.saveList(
          _cacheKey(trimmedId),
          [
            {
              ...doc.data()!,
              'id': doc.id,
            },
          ],
        );
      } catch (_) {}

      return bergerie;
    } catch (_) {
      final cached = await _cache.loadList(_cacheKey(trimmedId));
      if (cached == null || cached.isEmpty) {
        return null;
      }

      try {
        return BergerieModel.fromMap({
          ...cached.first,
          'id': cached.first['id']?.toString() ?? trimmedId,
        });
      } catch (_) {
        return null;
      }
    }
  }
  Future<BergerieModel?> getBergerieBySlug(String slug) async {
    final trimmedSlug = slug.trim().toLowerCase();
    if (trimmedSlug.isEmpty) return null;

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('slug', isEqualTo: trimmedSlug)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final bergerie = BergerieModel.fromMap({
          ...doc.data(),
          'id': doc.id,
        });

        try {
          await _cache.saveList(
            _cacheKey(doc.id),
            [{...doc.data(), 'id': doc.id}],
          );
        } catch (_) {}

        return bergerie;
      }

      // Compatibilité avec les bergeries créées avant l'introduction
      // du champ slug : on recalcule le slug à partir du nom.
      final all = await _firestore
          .collection(_collection)
          .get();

      for (final doc in all.docs) {
        final data = doc.data();
        final bergerie = BergerieModel.fromMap({
          ...data,
          'id': doc.id,
        });

        if (bergerie.slugEffectif == trimmedSlug) {
          try {
            await _cache.saveList(
              _cacheKey(doc.id),
              [{
                ...data,
                'id': doc.id,
                'slug': bergerie.slugEffectif,
              }],
            );
          } catch (_) {}

          // Migration douce : l'ancienne bergerie reçoit automatiquement
          // son slug dans Firestore.
          try {
            await _firestore
                .collection(_collection)
                .doc(doc.id)
                .set(
              {'slug': bergerie.slugEffectif},
              SetOptions(merge: true),
            );
          } catch (_) {}

          return bergerie;
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Résout une URL publique sans authentification.
  ///
  /// La collection bergerie_public_config est lisible publiquement
  /// par les règles Firestore. On utilise donc son nom pour résoudre
  /// le slug avant la connexion de l'utilisateur.
  Future<String?> getBergerieIdByPublicSlug(String slug) async {
    final trimmedSlug = slug.trim().toLowerCase();
    if (trimmedSlug.isEmpty) return null;

    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> chargerConfigs(
      Source source,
    ) async {
      final snapshot = await _firestore
          .collection('bergerie_public_config')
          .get(GetOptions(source: source));
      return snapshot.docs;
    }

    // La configuration publique est lisible sans authentification.
    // On privilégie le serveur, puis le cache Firestore si le serveur
    // n'est momentanément pas disponible (notamment juste après
    // une déconnexion ou hors connexion).
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];
    try {
      docs = await chargerConfigs(Source.server);
    } catch (_) {
      try {
        docs = await chargerConfigs(Source.cache);
      } catch (_) {
        docs = [];
      }
    }

    for (final doc in docs) {
      final data = doc.data();
      final nom = data['nomBergerie']?.toString() ?? '';
      final slugNom = BergerieModel.slugifier(nom);
      final slugSansPrefixe = slugNom.startsWith('bergerie-')
          ? slugNom.substring('bergerie-'.length)
          : slugNom;

      // Accepte le slug complet généré à partir du nom
      // (ex. bergerie-test-cayor) ainsi que sa forme courte
      // (ex. test-cayor), utilisée par certains liens d'accès.
      if ((slugNom == trimmedSlug ||
              slugSansPrefixe == trimmedSlug) &&
          data['active'] != false) {
        final id = data['bergerieId']?.toString().trim();
        return id != null && id.isNotEmpty ? id : doc.id;
      }
    }

    // Compatibilité immédiate avec la bergerie modèle.
    if (trimmedSlug == 'baraka') {
      return '8e870f6d-1f3a-4ce8-b1d6-2dff3be364b3';
    }

    return null;
  }

  // ====================================================
  // BERGERIES D'UN CLIENT
  // ====================================================

  Future<List<BergerieModel>> getBergeriesByClient(
      String clientId,
      ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
      'clientId',
      isEqualTo: clientId,
    )
        .get();

    final liste = snapshot.docs
        .map(
          (doc) => BergerieModel.fromMap({
        ...doc.data(),
        'id': doc.id,
      }),
    )
        .toList();

    liste.sort(
          (a, b) => a.nom.compareTo(b.nom),
    );

    return liste;
  }
}