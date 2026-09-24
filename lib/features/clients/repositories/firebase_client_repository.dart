import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/current_user_service.dart';
import '../../../core/session/local_business_cache_service.dart';
import '../models/client_model.dart';

class FirebaseClientRepository {
  FirebaseClientRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
      firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'clients';

  final LocalBusinessCacheService _cache =
      LocalBusinessCacheService.instance;

  String _cacheKey(String id) => 'client_$id';

  CollectionReference<Map<String, dynamic>>
  get _clients => _firestore.collection(_collection);

  Future<List<ClientModel>> getClients() async {
    final session = CurrentUserService.instance;

    if (session.isAdmin || session.isResponsable) {
      final snapshot = await _clients.get();

      return snapshot.docs
          .map(
            (doc) => ClientModel.fromMap(
          doc.data(),
          doc.id,
        ),
      )
          .toList();
    }

    final utilisateur = session.currentUser;

    if (utilisateur == null) {
      return [];
    }

    final snapshot = await _clients
        .where(
      'telephone',
      isEqualTo: utilisateur.telephone,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) => ClientModel.fromMap(
        doc.data(),
        doc.id,
      ),
    )
        .toList();
  }

  Future<ClientModel?> getClientById(
      String id,
      ) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      return null;
    }

    try {
      final doc = await _clients
          .doc(trimmedId)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final client = ClientModel.fromMap(
        doc.data()!,
        doc.id,
      );

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

      return client;
    } catch (_) {
      final cached = await _cache.loadList(_cacheKey(trimmedId));
      if (cached == null || cached.isEmpty) {
        return null;
      }

      try {
        final map = {
          ...cached.first,
        };
        final cachedId = map.remove('id')?.toString() ?? trimmedId;
        return ClientModel.fromMap(map, cachedId);
      } catch (_) {
        return null;
      }
    }
  }
  // ==========================================================
  // AJOUTER UN CLIENT
  // ==========================================================

  Future<void> addClient(
      ClientModel client,
      ) async {
    final telephone = client.telephone.trim();

    if (telephone.isEmpty) {
      throw Exception(
        "Le numéro de téléphone est obligatoire.",
      );
    }

    // Vérification d'un éventuel doublon.
    final snapshot = await _clients
        .where(
      'telephone',
      isEqualTo: telephone,
    )
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      throw Exception(
        "Un client existe déjà avec ce numéro de téléphone.",
      );
    }

    await _clients
        .doc(client.id)
        .set(client.toMap());
  }

  // ==========================================================
  // MODIFIER UN CLIENT
  // ==========================================================

  Future<void> updateClient(
      ClientModel client,
      ) async {
    final telephone = client.telephone.trim();

    if (telephone.isEmpty) {
      throw Exception(
        "Le numéro de téléphone est obligatoire.",
      );
    }

    // On vérifie que le numéro n'est pas déjà utilisé
    // par un autre client.
    final snapshot = await _clients
        .where(
      'telephone',
      isEqualTo: telephone,
    )
        .get();

    final doublon = snapshot.docs.any(
          (doc) => doc.id != client.id,
    );

    if (doublon) {
      throw Exception(
        "Un autre client utilise déjà ce numéro de téléphone.",
      );
    }

    await _clients
        .doc(client.id)
        .update(client.toMap());
  }

  // ==========================================================
  // SUPPRIMER UN CLIENT
  // ==========================================================

  Future<void> deleteClient(
      String id,
      ) async {
    await _clients.doc(id).delete();
  }

  // ==========================================================
  // FLUX TEMPS RÉEL
  // ==========================================================

  Stream<List<ClientModel>> watchClients() {
    return _clients.snapshots().map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => ClientModel.fromMap(
          doc.data(),
          doc.id,
        ),
      )
          .toList(),
    );
  }

  // ==========================================================
  // VÉRIFIER UN CLIENT PAR ID
  // ==========================================================

  Future<bool> clientExiste(
      String id,
      ) async {
    final doc = await _clients.doc(id).get();

    return doc.exists;
  }

  // ==========================================================
  // NOMBRE TOTAL DE CLIENTS
  // ==========================================================

  Future<int> getNombreClients() async {
    final snapshot = await _clients.get();

    return snapshot.size;
  }

  // ==========================================================
  // RECHERCHE
  // ==========================================================

  Future<List<ClientModel>> rechercherClients(
      String recherche,
      ) async {
    final clients = await getClients();

    final filtre =
    recherche.toLowerCase().trim();

    return clients.where((client) {
      return client.nom
          .toLowerCase()
          .contains(filtre) ||
          client.telephone
              .toLowerCase()
              .contains(filtre) ||
          client.quartier
              .toLowerCase()
              .contains(filtre);
    }).toList();
  }
}