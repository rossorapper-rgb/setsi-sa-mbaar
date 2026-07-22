import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlanningStatusFilter {
  tous,
  planifiee,
  enCours,
  terminee,
}

final planningStatusFilterProvider =
StateProvider<PlanningStatusFilter>(
      (ref) => PlanningStatusFilter.tous,
);

extension PlanningStatusFilterExtension
on PlanningStatusFilter {
  String get label {
    switch (this) {
      case PlanningStatusFilter.tous:
        return "Tous";
      case PlanningStatusFilter.planifiee:
        return "Planifiée";
      case PlanningStatusFilter.enCours:
        return "En cours";
      case PlanningStatusFilter.terminee:
        return "Terminée";
    }
  }

  String? get statut {
    switch (this) {
      case PlanningStatusFilter.tous:
        return null;
      case PlanningStatusFilter.planifiee:
        return "Planifiée";
      case PlanningStatusFilter.enCours:
        return "En cours";
      case PlanningStatusFilter.terminee:
        return "Terminée";
    }
  }
}