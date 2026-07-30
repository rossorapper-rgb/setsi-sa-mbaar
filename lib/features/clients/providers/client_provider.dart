import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/client_model.dart';
import '../repositories/firebase_client_repository.dart';

/// Repository Firebase
final firebaseClientRepositoryProvider =
Provider<FirebaseClientRepository>((ref) {
  return FirebaseClientRepository();
});

/// Flux temps réel des clients
final clientsProvider =
StreamProvider<List<ClientModel>>((ref) {
  final repository =
  ref.watch(firebaseClientRepositoryProvider);

  return repository.watchClients();
});

/// Nombre total de clients
final nombreClientsProvider =
FutureProvider<int>((ref) async {
  final repository =
  ref.watch(firebaseClientRepositoryProvider);

  return repository.getNombreClients();
});

/// Chargement classique de tous les clients
final clientsFutureProvider =
FutureProvider<List<ClientModel>>((ref) async {
  final repository =
  ref.watch(firebaseClientRepositoryProvider);

  return repository.getClients();
});
/// Vérifie si un client existe
final clientExisteProvider =
FutureProvider.family<bool, String>(
      (ref, clientId) async {
    final repository =
    ref.watch(firebaseClientRepositoryProvider);

    return repository.clientExiste(clientId);
  },
);

/// Recherche de clients
final rechercheClientsProvider =
FutureProvider.family<List<ClientModel>, String>(
      (ref, recherche) async {
    final repository =
    ref.watch(firebaseClientRepositoryProvider);

    if (recherche.trim().isEmpty) {
      return repository.getClients();
    }

    return repository.rechercherClients(recherche);
  },
);

/// Récupération d'un client par son identifiant
final clientByIdProvider =
FutureProvider.family<ClientModel?, String>(
      (ref, clientId) async {
    final repository =
    ref.watch(firebaseClientRepositoryProvider);

    return repository.getClientById(clientId);
  },
);
/// Contrôleur principal des opérations CRUD
class ClientNotifier extends StateNotifier<AsyncValue<void>> {
ClientNotifier(this._repository)
: super(const AsyncData(null));

final FirebaseClientRepository _repository;

/// Ajouter un client
Future<void> ajouterClient(
ClientModel client,
) async {
state = const AsyncLoading();

try {
await _repository.addClient(client);

state = const AsyncData(null);
} catch (e, stack) {
state = AsyncError(e, stack);
}
}

/// Modifier un client
Future<void> modifierClient(
ClientModel client,
) async {
state = const AsyncLoading();

try {
await _repository.updateClient(client);

state = const AsyncData(null);
} catch (e, stack) {
state = AsyncError(e, stack);
}
}
/// Supprimer un client
Future<void> supprimerClient(
    String clientId,
    ) async {
  state = const AsyncLoading();

  try {
    await _repository.deleteClient(clientId);

    state = const AsyncData(null);
  } catch (e, stack) {
    state = AsyncError(e, stack);
  }
}

/// Vérifie si un client existe
Future<bool> existe(
    String clientId,
    ) async {
  return _repository.clientExiste(clientId);
}

/// Recharge les données
Future<List<ClientModel>> chargerClients() async {
  return _repository.getClients();
}
}
/// Provider du contrôleur CRUD
final clientNotifierProvider =
StateNotifierProvider<ClientNotifier, AsyncValue<void>>(
      (ref) {
    final repository =
    ref.watch(firebaseClientRepositoryProvider);

    return ClientNotifier(repository);
  },
);

/// Rafraîchir la liste des clients
final refreshClientsProvider =
Provider<Future<void> Function()>((ref) {
  return () async {
    ref.invalidate(clientsProvider);
    ref.invalidate(clientsFutureProvider);
    ref.invalidate(nombreClientsProvider);
  };
});

/// Recherche locale (filtre instantané)
final rechercheClientTexteProvider =
StateProvider<String>(
      (ref) => '',
);
/// Liste filtrée suivant le texte de recherche
final clientsFiltresProvider =
Provider<AsyncValue<List<ClientModel>>>((ref) {
  final clientsAsync = ref.watch(clientsProvider);
  final recherche = ref.watch(rechercheClientTexteProvider);

  return clientsAsync.whenData((clients) {
    final filtre = recherche.trim().toLowerCase();

    if (filtre.isEmpty) {
      return clients;
    }

    return clients.where((client) {
      return client.nom.toLowerCase().contains(filtre) ||
          client.telephone.toLowerCase().contains(filtre) ||
          client.quartier.toLowerCase().contains(filtre) ||
          client.id.toLowerCase().contains(filtre);
    }).toList();
  });
});

/// Nombre de clients actifs
final nombreClientsActifsProvider =
Provider<AsyncValue<int>>((ref) {
  final clientsAsync = ref.watch(clientsProvider);

  return clientsAsync.whenData(
        (clients) => clients.where((c) => c.actif).length,
  );
});
/// Nombre total de moutons enregistrés chez tous les clients
final nombreTotalMoutonsProvider =
Provider<AsyncValue<int>>((ref) {
  final clientsAsync = ref.watch(clientsProvider);

  return clientsAsync.whenData(
        (clients) => clients.fold<int>(
      0,
          (total, client) => total + client.nombreMoutons,
    ),
  );
});

/// Nombre total de troupeaux enregistrés
final nombreTotalTroupeauxProvider =
Provider<AsyncValue<int>>((ref) {
  final clientsAsync = ref.watch(clientsProvider);

  return clientsAsync.whenData(
        (clients) => clients.fold<int>(
      0,
          (total, client) => total + client.nombreTroupeaux,
    ),
  );
});

/// Clients actifs uniquement
final clientsActifsProvider =
Provider<AsyncValue<List<ClientModel>>>((ref) {
  final clientsAsync = ref.watch(clientsProvider);

  return clientsAsync.whenData(
        (clients) => clients.where((c) => c.actif).toList(),
  );
});
/// Répartition des abonnements
final repartitionAbonnementsProvider =
Provider<AsyncValue<Map<String, int>>>((ref) {
  final clientsAsync = ref.watch(clientsProvider);

  return clientsAsync.whenData((clients) {
    final Map<String, int> resultat = {};

    for (final client in clients) {
      final abonnement = client.abonnement.trim();

      resultat.update(
        abonnement,
            (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return resultat;
  });
});

/// Dernière liste disponible de clients
final listeClientsProvider =
Provider<List<ClientModel>>((ref) {
  final clients = ref.watch(clientsProvider);

  return clients.maybeWhen(
    data: (liste) => liste,
    orElse: () => const <ClientModel>[],
  );
});

/// Premier client correspondant à un identifiant
final clientSelectionneProvider =
Provider.family<ClientModel?, String>((ref, clientId) {
  final clients = ref.watch(listeClientsProvider);

  try {
    return clients.firstWhere(
          (client) => client.id == clientId,
    );
  } catch (_) {
    return null;
  }
});