class InterventionModel {
  final String id;
  final String heure;
  final String client;
  final String quartier;
  final String service;
  final String statut;

  const InterventionModel({
    required this.id,
    required this.heure,
    required this.client,
    required this.quartier,
    required this.service,
    required this.statut,
  });

  bool get isFinished => statut == "Terminée";
  bool get isRunning => statut == "En cours";
  bool get isPending => statut == "À venir";
}