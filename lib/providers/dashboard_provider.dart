import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  String get revenusFormat =>
      "${(revenus / 1000000).toStringAsFixed(1)} M FCFA";
}

final dashboardProvider = Provider<DashboardState>((ref) {
  return const DashboardState(
    clients: 128,
    moutons: 325,
    bergeries: 18,
    gestations: 27,
    interventions: 42,
    revenus: 3200000,
  );
});