import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/session/current_user_service.dart';
import '../features/clients/repositories/firebase_client_repository.dart';
import '../features/bergeries/repository/firebase_bergerie_repository.dart';

class DashboardState {
  final int clients;
  final int clientsActifs;
  final int bergeries;
  final int bergeriesActives;

  final int moutons;
  final int gestations;
  final int interventions;
  final double revenus;

  const DashboardState({
    required this.clients,
    required this.bergeries,
    this.clientsActifs = 0,
    this.bergeriesActives = 0,
    this.moutons = 0,
    this.gestations = 0,
    this.interventions = 0,
    this.revenus = 0,
  });

  String get revenusFormat {
    if (revenus >= 1000000) {
      return "${(revenus / 1000000).toStringAsFixed(1)} M FCFA";
    }
    return "${revenus.toStringAsFixed(0)} FCFA";
  }
}

final dashboardProvider = FutureProvider<DashboardState>((ref) async {
  final session = CurrentUserService.instance;

  if (session.currentUser == null || !session.isAdmin) {
    return const DashboardState(
      clients: 0,
      clientsActifs: 0,
      bergeries: 0,
      bergeriesActives: 0,
    );
  }

  final results = await Future.wait([
    FirebaseClientRepository().getClients(),
    FirebaseBergerieRepository().getAllBergeries(),
  ]);

  final clients = results[0];
  final bergeries = results[1];

  return DashboardState(
    clients: clients.length,
    clientsActifs: clients.where((client) => client.actif).length,
    bergeries: bergeries.length,
    bergeriesActives: bergeries.where((bergerie) => bergerie.active).length,
  );
});
