import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/current_user_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/client_model.dart';

class FirebaseClientRepository {
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

static const String _collection = 'clients';

CollectionReference<Map<String, dynamic>> get _clients =>
_firestore.collection(_collection);

Future<List<ClientModel>> getClients() async {
if (AuthService.instance.isAdmin ||
AuthService.instance.isResponsable) {
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

final utilisateur = CurrentUserService.instance.currentUser;

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
  if (AuthService.instance.isAdmin ||
      AuthService.instance.isResponsable) {
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

  final utilisateur = CurrentUserService.instance.currentUser;

  if (utilisateur == null) {
    return const Stream.empty();
  }

  return _clients
      .where(
    'telephone',
    isEqualTo: utilisateur.telephone,
  )
      .snapshots()
      .map(
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
  final clients = await getClients();
  return clients.length;
}

Future<List<ClientModel>> rechercherClients(
    String recherche,
    ) async {
  final clients = await getClients();

  final filtre = recherche.toLowerCase().trim();

  return clients.where((client) {
    return client.nom.toLowerCase().contains(filtre) ||
        client.telephone.toLowerCase().contains(filtre) ||
        client.quartier.toLowerCase().contains(filtre);
  }).toList();
}
}