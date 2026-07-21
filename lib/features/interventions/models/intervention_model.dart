class InterventionModel {
  final String id;
  final String numero;

  // Client
  final String clientId;
  final String clientNom;

  // Planification
  final DateTime dateIntervention;
  final String heureDebut;
  final String heureFin;

  // Prestations
  final bool lavage;
  final bool nettoyageBergerie;
  final bool desinfection;

  // Ressources
  final String agent;
  final String vehicule;

  // Suivi
  final int nombreMoutons;
  final String observations;

  // Statut
  final String statut;

  const InterventionModel({
    required this.id,
    required this.numero,
    required this.clientId,
    required this.clientNom,
    required this.dateIntervention,
    required this.heureDebut,
    required this.heureFin,
    required this.lavage,
    required this.nettoyageBergerie,
    required this.desinfection,
    required this.agent,
    required this.vehicule,
    required this.nombreMoutons,
    required this.observations,
    required this.statut,
  });

  InterventionModel copyWith({
    String? id,
    String? numero,
    String? clientId,
    String? clientNom,
    DateTime? dateIntervention,
    String? heureDebut,
    String? heureFin,
    bool? lavage,
    bool? nettoyageBergerie,
    bool? desinfection,
    String? agent,
    String? vehicule,
    int? nombreMoutons,
    String? observations,
    String? statut,
  }) {
    return InterventionModel(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      clientId: clientId ?? this.clientId,
      clientNom: clientNom ?? this.clientNom,
      dateIntervention: dateIntervention ?? this.dateIntervention,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      lavage: lavage ?? this.lavage,
      nettoyageBergerie:
      nettoyageBergerie ?? this.nettoyageBergerie,
      desinfection: desinfection ?? this.desinfection,
      agent: agent ?? this.agent,
      vehicule: vehicule ?? this.vehicule,
      nombreMoutons: nombreMoutons ?? this.nombreMoutons,
      observations: observations ?? this.observations,
      statut: statut ?? this.statut,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'clientId': clientId,
      'clientNom': clientNom,
      'dateIntervention':
      dateIntervention.toIso8601String(),
      'heureDebut': heureDebut,
      'heureFin': heureFin,
      'lavage': lavage,
      'nettoyageBergerie': nettoyageBergerie,
      'desinfection': desinfection,
      'agent': agent,
      'vehicule': vehicule,
      'nombreMoutons': nombreMoutons,
      'observations': observations,
      'statut': statut,
    };
  }

  factory InterventionModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return InterventionModel(
      id: map['id'] ?? '',
      numero: map['numero'] ?? '',
      clientId: map['clientId'] ?? '',
      clientNom: map['clientNom'] ?? '',
      dateIntervention: DateTime.parse(
        map['dateIntervention'],
      ),
      heureDebut: map['heureDebut'] ?? '',
      heureFin: map['heureFin'] ?? '',
      lavage: map['lavage'] ?? false,
      nettoyageBergerie:
      map['nettoyageBergerie'] ?? false,
      desinfection: map['desinfection'] ?? false,
      agent: map['agent'] ?? '',
      vehicule: map['vehicule'] ?? '',
      nombreMoutons: map['nombreMoutons'] ?? 0,
      observations: map['observations'] ?? '',
      statut: map['statut'] ?? '',
    );
  }
}