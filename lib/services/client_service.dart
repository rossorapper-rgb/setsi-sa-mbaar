import '../models/client_model.dart';
import '../repositories/client_repository.dart';

class ClientService {
  ClientService({ClientRepository? repository})
      : _repository = repository ?? ClientRepository();

  final ClientRepository _repository;

  /// Retourne tous les clients en temps réel
  Stream<List<ClientModel>> getClients() {
    return _repository.getClients();
  }

  /// Retourne le nombre total de clients
  Future<int> getClientsCount() {
    return _repository.getClientsCount();
  }

  /// Retourne un client à partir de son identifiant
  Future<ClientModel?> getClient(String id) {
    return _repository.getClient(id);
  }

  /// Ajouter un client
  Future<void> addClient(ClientModel client) async {
    _validateClient(client);

    final clientToSave = client.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.addClient(clientToSave);
  }

  /// Modifier un client
  Future<void> updateClient(ClientModel client) async {
    _validateClient(client);

    final clientToUpdate = client.copyWith(
      updatedAt: DateTime.now(),
    );

    await _repository.updateClient(clientToUpdate);
  }

  /// Supprimer un client
  Future<void> deleteClient(String id) async {
    await _repository.deleteClient(id);
  }

  /// Validation des données
  void _validateClient(ClientModel client) {
    if (client.nom.trim().isEmpty) {
      throw Exception("Le nom du client est obligatoire.");
    }

    if (client.telephone.trim().isEmpty) {
      throw Exception("Le numéro de téléphone est obligatoire.");
    }

    if (client.adresse.trim().isEmpty) {
      throw Exception("L'adresse est obligatoire.");
    }

    if (client.quartier.trim().isEmpty) {
      throw Exception("Le quartier est obligatoire.");
    }

    if (client.nombreMoutons < 0) {
      throw Exception("Le nombre de moutons est invalide.");
    }

    if (client.nombreTroupeaux < 0) {
      throw Exception("Le nombre de troupeaux est invalide.");
    }
  }
}