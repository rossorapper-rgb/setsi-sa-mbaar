import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/current_user_service.dart';
import '../../../core/session/local_business_cache_service.dart';
import '../models/stock_produit_model.dart';
import '../models/stock_mouvement_model.dart';

class FirebaseStockRepository {
  FirebaseStockRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final LocalBusinessCacheService _cache =
      LocalBusinessCacheService.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('stock_produits');

  String get _bergerieId {
    final id = CurrentUserService.instance.bergerieId?.trim();
    if (id == null || id.isEmpty) {
      throw StateError('Aucune bergerie associée à cet utilisateur.');
    }
    return id;
  }

  String _cacheKey(String bergerieId) => 'stock_produits_$bergerieId';

  Future<List<StockProduitModel>> getProduits() async {
    final bergerieId = _bergerieId;

    try {
      final snapshot = await _collection
          .where('bergerieId', isEqualTo: bergerieId)
          .get(const GetOptions(source: Source.server));

      final produits = snapshot.docs
          .map(
            (doc) => StockProduitModel.fromMap({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();

      produits.sort(
        (a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()),
      );

      await _cache.saveList(
        _cacheKey(bergerieId),
        produits
            .map(
              (produit) => {
                'id': produit.id,
                ...produit.toMap(),
              },
            )
            .toList(),
      );

      return produits;
    } catch (_) {
      final cached = await _cache.loadList(_cacheKey(bergerieId));
      if (cached == null) return [];

      final produits = cached.map(StockProduitModel.fromMap).toList();
      produits.sort(
        (a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()),
      );
      return produits;
    }
  }

  Future<List<StockMouvementModel>> getMouvements() async {
    final bergerieId = _bergerieId;
    final cacheKey = 'stock_mouvements_$bergerieId';

    try {
      final snapshot = await _firestore
          .collection('stock_mouvements')
          .where('bergerieId', isEqualTo: bergerieId)
          .get(const GetOptions(source: Source.server));

      final mouvements = snapshot.docs
          .map(
            (doc) => StockMouvementModel.fromMap({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();

      mouvements.sort((a, b) => b.date.compareTo(a.date));

      await _cache.saveList(
        cacheKey,
        mouvements
            .map(
              (mouvement) => {
                'id': mouvement.id,
                ...mouvement.toMap(),
              },
            )
            .toList(),
      );

      return mouvements;
    } catch (_) {
      final cached = await _cache.loadList(cacheKey);
      if (cached == null) return [];

      final mouvements = cached
          .map(StockMouvementModel.fromMap)
          .toList();

      mouvements.sort((a, b) => b.date.compareTo(a.date));
      return mouvements;
    }
  }

  Future<StockProduitModel> ajouterProduit({
    required String nom,
    required String categorie,
    required String unite,
    required double quantite,
    required double seuilMinimum,
    required double prixUnitaire,
    bool actif = true,
  }) async {
    final bergerieId = _bergerieId;
    final doc = _collection.doc();

    final produit = StockProduitModel(
      id: doc.id,
      bergerieId: bergerieId,
      nom: nom.trim(),
      categorie: categorie.trim(),
      unite: unite.trim(),
      quantite: quantite,
      seuilMinimum: seuilMinimum,
      prixUnitaire: prixUnitaire,
      actif: actif,
    );

    await doc.set(produit.toMap());
    await getProduits();
    return produit;
  }

  Future<void> enregistrerEntree({
    required String produitId,
    required double quantite,
    required String motif,
    required DateTime date,
    required double prix,
    String fournisseur = '',
    String note = '',
  }) async {
    final bergerieId = _bergerieId;
    if (quantite <= 0) {
      throw ArgumentError('La quantité doit être supérieure à zéro.');
    }

    final produitRef = _collection.doc(produitId);
    final mouvementRef = _firestore.collection('stock_mouvements').doc();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(produitRef);
      if (!snapshot.exists) {
        throw StateError('Produit introuvable.');
      }

      final produit = StockProduitModel.fromMap({
        ...snapshot.data()!,
        'id': snapshot.id,
      });
      if (produit.bergerieId != bergerieId) {
        throw StateError('Ce produit n’appartient pas à votre bergerie.');
      }

      transaction.update(produitRef, {
        'quantite': produit.quantite + quantite,
      });
      transaction.set(
        mouvementRef,
        {
          'bergerieId': bergerieId,
          'produitId': produitId,
          'type': 'entree',
          'quantite': quantite,
          'date': Timestamp.fromDate(date),
          'motif': motif.trim(),
          'prix': prix,
          'fournisseur': fournisseur.trim(),
          'note': note.trim(),
        },
      );
    });

    await getProduits();
    await getMouvements();
  }

  Future<void> enregistrerSortie({
    required String produitId,
    required double quantite,
    required String motif,
    required DateTime date,
    String note = '',
  }) async {
    final bergerieId = _bergerieId;
    if (quantite <= 0) throw ArgumentError('La quantité doit être supérieure à zéro.');
    final produitRef = _collection.doc(produitId);
    final mouvementRef = _firestore.collection('stock_mouvements').doc();
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(produitRef);
      if (!snapshot.exists) throw StateError('Produit introuvable.');
      final produit = StockProduitModel.fromMap({...snapshot.data()!, 'id': snapshot.id});
      if (produit.bergerieId != bergerieId) throw StateError('Ce produit n’appartient pas à votre bergerie.');
      if (quantite > produit.quantite) throw StateError('Stock insuffisant. Stock disponible : ' + produit.quantite.toString() + ' ' + produit.unite + '.');
      transaction.update(produitRef, {'quantite': produit.quantite - quantite});
      transaction.set(mouvementRef, {
        'bergerieId': bergerieId, 'produitId': produitId, 'type': 'sortie',
        'quantite': quantite, 'date': Timestamp.fromDate(date), 'motif': motif.trim(),
        'prix': produit.prixUnitaire, 'fournisseur': '', 'note': note.trim(),
      });
    });
    await getProduits();
    await getMouvements();
  }
  Future<void> deduireDepuisAlimentation({
    required String alimentationId,
    required String produitId,
    required double quantite,
    required String motif,
    required DateTime date,
  }) async {
    final bergerieId = _bergerieId;
    if (quantite <= 0) throw ArgumentError('La quantité doit être supérieure à zéro.');
    final produitRef = _collection.doc(produitId);
    final alimentationRef = _firestore.collection('alimentations').doc(alimentationId);
    final mouvementRef = _firestore.collection('stock_mouvements').doc();
    await _firestore.runTransaction((transaction) async {
      final produitSnap = await transaction.get(produitRef);
      final alimentationSnap = await transaction.get(alimentationRef);
      if (!produitSnap.exists) throw StateError('Produit de stock introuvable.');
      if (!alimentationSnap.exists) throw StateError('Enregistrement d’alimentation introuvable.');
      final produit = StockProduitModel.fromMap({...produitSnap.data()!, 'id': produitSnap.id});
      final alimentation = alimentationSnap.data()!;
      if (produit.bergerieId != bergerieId || alimentation['bergerieId']?.toString() != bergerieId) {
        throw StateError('Les données n’appartiennent pas à votre bergerie.');
      }
      if (alimentation['stockDeduit'] == true) {
        throw StateError('Cette alimentation a déjà été déduite du stock.');
      }
      if (quantite > produit.quantite) {
        throw StateError('Stock insuffisant. Stock disponible : ${produit.quantite} ${produit.unite}.');
      }
      transaction.update(produitRef, {'quantite': produit.quantite - quantite});
      transaction.set(mouvementRef, {
        'bergerieId': bergerieId,
        'produitId': produitId,
        'type': 'sortie',
        'quantite': quantite,
        'date': Timestamp.fromDate(date),
        'motif': motif.trim(),
        'prix': produit.prixUnitaire,
        'fournisseur': '',
        'note': 'Source alimentation : $alimentationId',
        'source': 'alimentation',
        'sourceId': alimentationId,
      });
      transaction.update(alimentationRef, {
        'stockDeduit': true,
        'stockMouvementId': mouvementRef.id,
      });
    });
    await getProduits();
    await getMouvements();
  }
  Future<void> deduireDepuisCarnetSante({
    required String soinId,
    required String produitId,
    required double quantite,
    required String motif,
    required DateTime date,
  }) async {
    final bergerieId = _bergerieId;
    if (quantite <= 0) throw ArgumentError('La quantité doit être supérieure à zéro.');
    final produitRef = _collection.doc(produitId);
    final soinRef = _firestore.collection('carnet_sante').doc(soinId);
    final mouvementRef = _firestore.collection('stock_mouvements').doc();
    await _firestore.runTransaction((transaction) async {
      final produitSnap = await transaction.get(produitRef);
      final soinSnap = await transaction.get(soinRef);
      if (!produitSnap.exists) throw StateError('Produit de stock introuvable.');
      if (!soinSnap.exists) throw StateError('Soin introuvable.');
      final produit = StockProduitModel.fromMap({...produitSnap.data()!, 'id': produitSnap.id});
      final soin = soinSnap.data()!;
      if (produit.bergerieId != bergerieId || soin['bergerieId']?.toString() != bergerieId) {
        throw StateError('Les données n’appartiennent pas à votre bergerie.');
      }
      if (soin['stockDeduit'] == true) throw StateError('Ce soin a déjà été déduit du stock.');
      if (quantite > produit.quantite) throw StateError('Stock insuffisant. Stock disponible : ${produit.quantite} ${produit.unite}.');
      transaction.update(produitRef, {'quantite': produit.quantite - quantite});
      transaction.set(mouvementRef, {
        'bergerieId': bergerieId, 'produitId': produitId, 'type': 'sortie',
        'quantite': quantite, 'date': Timestamp.fromDate(date), 'motif': motif.trim(),
        'prix': produit.prixUnitaire, 'fournisseur': '',
        'note': 'Source carnet de santé : $soinId', 'source': 'carnet_sante', 'sourceId': soinId,
      });
      transaction.update(soinRef, {'stockDeduit': true, 'stockMouvementId': mouvementRef.id});
    });
    await getProduits();
    await getMouvements();
  }
  Future<void> deduireDepuisIntervention({
    required String interventionId,
    required String produitId,
    required double quantite,
    required String motif,
    required DateTime date,
  }) async {
    final bergerieId = _bergerieId;
    if (quantite <= 0) {
      throw ArgumentError('La quantité doit être supérieure à zéro.');
    }

    final produitRef = _collection.doc(produitId);
    final interventionRef =
        _firestore.collection('interventions').doc(interventionId);
    final mouvementRef = _firestore.collection('stock_mouvements').doc();

    // Sur Flutter Web, une exception lancée directement à l'intérieur du
    // callback de runTransaction peut être transformée en message générique
    // "Dart exception thrown from converted Future". On retourne donc le
    // message de validation depuis la transaction, puis on lève l'erreur
    // après la transaction.
    final erreur = await _firestore.runTransaction<String?>((transaction) async {
      final produitSnap = await transaction.get(produitRef);
      final interventionSnap = await transaction.get(interventionRef);

      if (!produitSnap.exists) {
        return 'Produit de stock introuvable.';
      }
      if (!interventionSnap.exists) {
        return 'Intervention introuvable.';
      }

      final produit = StockProduitModel.fromMap({
        ...produitSnap.data()!,
        'id': produitSnap.id,
      });
      final intervention = interventionSnap.data()!;

      if (produit.bergerieId != bergerieId ||
          intervention['bergerieId']?.toString() != bergerieId) {
        return 'Les données n’appartiennent pas à votre bergerie.';
      }

      if (intervention['stockDeduit'] == true) {
        return 'Cette intervention a déjà été déduite du stock.';
      }

      if (quantite > produit.quantite) {
        return 'Stock insuffisant. Stock disponible : '
            '\${produit.quantite} \${produit.unite}.';
      }

      transaction.update(produitRef, {
        'quantite': produit.quantite - quantite,
      });

      transaction.set(mouvementRef, {
        'bergerieId': bergerieId,
        'produitId': produitId,
        'type': 'sortie',
        'quantite': quantite,
        'date': Timestamp.fromDate(date),
        'motif': motif.trim(),
        'prix': produit.prixUnitaire,
        'fournisseur': '',
        'note': 'Source intervention : $interventionId',
        'source': 'intervention',
        'sourceId': interventionId,
      });

      transaction.update(interventionRef, {
        'stockDeduit': true,
        'stockMouvementId': mouvementRef.id,
      });

      return null;
    });

    if (erreur != null) {
      throw StateError(erreur);
    }

    await getProduits();
    await getMouvements();
  }
  Future<void> modifierProduit(StockProduitModel produit) async {
    final bergerieId = _bergerieId;

    if (produit.bergerieId != bergerieId) {
      throw StateError('Ce produit n’appartient pas à votre bergerie.');
    }

    await _collection.doc(produit.id).update(produit.toMap());
    await getProduits();
  }

  Future<void> supprimerProduit(String id) async {
    final bergerieId = _bergerieId;
    final doc = await _collection.doc(id).get();

    if (!doc.exists) return;

    final produit = StockProduitModel.fromMap({
      ...doc.data()!,
      'id': doc.id,
    });

    if (produit.bergerieId != bergerieId) {
      throw StateError('Ce produit n’appartient pas à votre bergerie.');
    }

    await _collection.doc(id).delete();
    await getProduits();
  }
}
