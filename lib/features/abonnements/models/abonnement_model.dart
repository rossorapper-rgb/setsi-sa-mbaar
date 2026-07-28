class AbonnementModel {
  final String id;
  final String numero;

  // Client
  final String clientId;
  final String clientNom;

  // Bergerie
  final String bergerieId;
  final String bergerieNom;

  // Pack
  final String pack;
  final double montant;

  // Dates
  final DateTime dateDebut;
  final DateTime dateFin;

  // Paiement
  final double montantPaye;
  final double resteAPayer;

  // Statut
  final String statut;

  // Observations
  final String observations;

  final DateTime dateCreation;

  const AbonnementModel({
    required this.id,
    required this.numero,
    required this.clientId,
    required this.clientNom,
    required this.bergerieId,
    required this.bergerieNom,
    required this.pack,
    required this.montant,
    required this.dateDebut,
    required this.dateFin,
    required this.montantPaye,
    required this.resteAPayer,
    required this.statut,
    required this.observations,
    required this.dateCreation,
  });

  AbonnementModel copyWith({
    String? id,
    String? numero,
    String? clientId,
    String? clientNom,
    String? bergerieId,
    String? bergerieNom,
    String? pack,
    double? montant,
    DateTime? dateDebut,
    DateTime? dateFin,
    double? montantPaye,
    double? resteAPayer,
    String? statut,
    String? observations,
    DateTime? dateCreation,
  }) {
    return AbonnementModel(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      clientId: clientId ?? this.clientId,
      clientNom: clientNom ?? this.clientNom,
      bergerieId: bergerieId ?? this.bergerieId,
      bergerieNom: bergerieNom ?? this.bergerieNom,
      pack: pack ?? this.pack,
      montant: montant ?? this.montant,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      montantPaye: montantPaye ?? this.montantPaye,
      resteAPayer: resteAPayer ?? this.resteAPayer,
      statut: statut ?? this.statut,
      observations: observations ?? this.observations,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  bool get estActif => statut == "Actif";

  bool get estExpire => DateTime.now().isAfter(dateFin);

  int get joursRestants => dateFin.difference(DateTime.now()).inDays;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'clientId': clientId,
      'clientNom': clientNom,
      'bergerieId': bergerieId,
      'bergerieNom': bergerieNom,
      'pack': pack,
      'montant': montant,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
      'montantPaye': montantPaye,
      'resteAPayer': resteAPayer,
      'statut': statut,
      'observations': observations,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  factory AbonnementModel.fromMap(Map<String, dynamic> map) {
    return AbonnementModel(
      id: map['id'] ?? '',
      numero: map['numero'] ?? '',
      clientId: map['clientId'] ?? '',
      clientNom: map['clientNom'] ?? '',
      bergerieId: map['bergerieId'] ?? '',
      bergerieNom: map['bergerieNom'] ?? '',
      pack: map['pack'] ?? '',
      montant: (map['montant'] ?? 0).toDouble(),
      dateDebut: DateTime.parse(map['dateDebut']),
      dateFin: DateTime.parse(map['dateFin']),
      montantPaye: (map['montantPaye'] ?? 0).toDouble(),
      resteAPayer: (map['resteAPayer'] ?? 0).toDouble(),
      statut: map['statut'] ?? 'Actif',
      observations: map['observations'] ?? '',
      dateCreation: DateTime.parse(map['dateCreation']),
    );
  }
}
