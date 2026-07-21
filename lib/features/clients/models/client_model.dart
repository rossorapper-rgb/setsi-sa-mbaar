class ClientModel {
  final String id;
  final String nom;
  final String telephone;
  final String quartier;
  final String adresse;
  final int nombreTroupeaux;
  final int nombreMoutons;
  final String abonnement;
  final bool actif;

  const ClientModel({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.quartier,
    required this.adresse,
    required this.nombreTroupeaux,
    required this.nombreMoutons,
    required this.abonnement,
    required this.actif,
  });

  String get statut => actif ? "Actif" : "Inactif";
}