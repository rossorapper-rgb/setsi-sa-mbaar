import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/current_user_service.dart';
import '../../../core/session/local_business_cache_service.dart';
import '../models/stock_produit_model.dart';

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
  }

  Future<void> modifierProduit(StockProduitModel produit) async {
    final bergerieId = _bergerieId;

    if (produit.bergerieId != bergerieId) {
      throw StateError('Ce produit n’appartient pas à votre bergerie.');
    }

    await _collection.doc(produit.id).update(produit.toMap());
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
  }
}
