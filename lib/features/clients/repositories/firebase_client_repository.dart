import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/client_model.dart';

class FirebaseClientRepository {
final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

static const String _collection =
'clients';

CollectionReference<Map<String, dynamic>>
get _clients =>
_firestore.collection(_collection);

Future<List<ClientModel>> getClients() async {
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

Future<ClientModel?> getClientById(
String id,
) async {
final doc = await _clients.doc(id).get();

if (!doc.exists || doc.data() == null) {
return null;
}

return ClientModel.fromMap(
doc.data()!,
doc.id,
);
}

Future<void> addClient(
ClientModel client,
) async {
await _clients
.doc(client.id)
.set(client.toMap());
}

Future<void> updateClient(
ClientModel client,
) async {
await _clients
.doc(client.id)
.update(client.toMap());
}
Future<void> deleteClient(
    String id,
    ) async {
  await _clients.doc(id).delete();
}

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

Future<bool> clientExiste(
    String id,
    ) async {
  final doc = await _clients.doc(id).get();
  return doc.exists;
}

Future<int> getNombreClients() async {
  final snapshot = await _clients.get();
  return snapshot.size;
}

Future<List<ClientModel>> rechercherClients(
    String recherche,
    ) async {
  final clients = await getClients();

  final filtre = recherche.toLowerCase().trim();

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
