import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/session/current_user_service.dart';
import '../features/auth/services/auth_service.dart';
import '../features/clients/repositories/firebase_client_repository.dart';
import '../features/bergeries/repository/firebase_bergerie_repository.dart';
import '../features/moutons/repository/firebase_mouton_repository.dart';
import '../features/interventions/repositories/firebase_intervention_repository.dart';
import '../features/finances/repository/firebase_paiement_repository.dart';
import '../features/gestation/repositories/firebase_gestation_repository.dart';

class DashboardState {
  final int clients;
  final int moutons;
  final int bergeries;
  final int gestations;
  final int interventions;
  final double revenus;

  const DashboardState({
    required this.clients,
    required this.moutons,
    required this.bergeries,
    required this.gestations,
    required this.interventions,
    required this.revenus,
  });

  String get revenusFormat {
    if (revenus >= 1000000) {
      return "${(revenus / 1000000).toStringAsFixed(1)} M FCFA";
    }

    if (revenus >= 1000) {
      return "${revenus.toStringAsFixed(0)} FCFA";
    }

    return "${revenus.toStringAsFixed(0)} FCFA";
  }
}

final dashboardProvider = FutureProvider<DashboardState>((ref) async {
  final auth = AuthService.instance;
  final currentUser = CurrentUserService.instance.currentUser;

  if (currentUser == null) {
    return const DashboardState(
      clients: 0,
      moutons: 0,
      bergeries: 0,
      gestations: 0,
      interventions: 0,
      revenus: 0,
    );
  }

  final clientRepository = FirebaseClientRepository();
  final bergerieRepository = FirebaseBergerieRepository();
  final moutonRepository = FirebaseMoutonRepository();
  final interventionRepository = FirebaseInterventionRepository();
  final paiementRepository = FirebasePaiementRepository();
  final gestationRepository = FirebaseGestationRepository();

  final bool gestionComplete =
      auth.isAdmin || auth.isResponsable;

  if (gestionComplete) {
    final results = await Future.wait([
      clientRepository.getClients(),
      bergerieRepository.getAllBergeries(),
      moutonRepository.getMoutons(),
      gestationRepository.getGestationsEnCours(),
      interventionRepository.getToutesLesInterventions(),
      paiementRepository.getRevenuTotal(),
    ]);

    return DashboardState(
      clients: (results[0] as List).length,
      bergeries: (results[1] as List).length,
      moutons: (results[2] as List).length,
      gestations: (results[3] as List).length,
      interventions: (results[4] as List).length,
      revenus: (results[5] as num).toDouble(),
    );
  }

  // ------------------------------------------------------
  // ESPACE CLIENT
  // ------------------------------------------------------

  final clients = await clientRepository.getClients();

  if (clients.isEmpty) {
    return const DashboardState(
      clients: 0,
      moutons: 0,
      bergeries: 0,
      gestations: 0,
      interventions: 0,
      revenus: 0,
    );
  }

  final client = clients.first;

  final bergeries =
  await bergerieRepository.getBergeriesByClient(client.id);

  int nombreMoutons = 0;
  int nombreGestations = 0;

  for (final bergerie in bergeries) {
    final moutons =
    await moutonRepository.getMoutonsByBergerie(
      bergerie.id,
    );

    nombreMoutons += moutons.length;

    final gestations =
    await gestationRepository.getGestationsParBergerie(
      bergerie.id,
    );

    nombreGestations += gestations
        .where(
          (gestation) => gestation.statut == 'Gestante',
    )
        .length;
  }

  final interventions =
  await interventionRepository.getInterventionsDuClient(
    client.id,
  );

  final paiements =
  await paiementRepository.getPaiementsDuClient(
    client.id,
  );

  final revenus = paiements
      .where((paiement) => paiement.actif)
      .fold<double>(
    0.0,
        (total, paiement) =>
    total + paiement.montantPaye,
  );

  return DashboardState(
    clients: 1,
    moutons: nombreMoutons,
    bergeries: bergeries.length,
    gestations: nombreGestations,
    interventions: interventions.length,
    revenus: revenus,
  );
});
