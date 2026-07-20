import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/client_model.dart';

class ClientRepository {
  ClientRepository();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _clients =>
      _firestore.collection('clients');

  /// Ajouter un client
  Future<void> addClient(ClientModel client) async {
    await _clients.add(client.toMap());
  }

  /// Modifier un client
  Future<void> updateClient(ClientModel client) async {
    await _clients.doc(client.id).update(client.toMap());
  }

  /// Supprimer un client
  Future<void> deleteClient(String id) async {
    await _clients.doc(id).delete();
  }

  /// Récupérer tous les clients
  Stream<List<ClientModel>> getClients() {
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

  /// Nombre total de clients
  Future<int> getClientsCount() async {
    final snapshot = await _clients.get();
    return snapshot.docs.length;
  }

  /// Récupérer un client
  Future<ClientModel?> getClient(String id) async {
    final doc = await _clients.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return ClientModel.fromMap(
      doc.data()!,
      doc.id,
    );
  }
}