class InterventionModel {
  final String id;
  final String numero;

  // Client
  final String clientId;
  final String clientNom;
  final String bergerieId;
  final String bergerieNom;
  final String origineIntervention;
  final String? abonnementId;

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
  final List<String> moutonsConcernes;
  final bool vermifugation;
  final String produitVermifuge;
  final DateTime? prochaineVermifugation;
  final bool traitementEnCours;
  final String maladie;
  final DateTime? finTraitement;
  final String observations;
  final String recommandations;

  // Statut
  final String statut;

  const InterventionModel({
    required this.id,
    required this.numero,
    required this.clientId,
    required this.clientNom,
    required this.bergerieId,
    required this.bergerieNom,
    required this.origineIntervention,
    this.abonnementId,
    required this.dateIntervention,
    required this.heureDebut,
    required this.heureFin,
    required this.lavage,
    required this.nettoyageBergerie,
    required this.desinfection,
    required this.agent,
    required this.vehicule,
    required this.nombreMoutons,
    this.moutonsConcernes = const [],
    this.vermifugation = false,
    this.produitVermifuge = "",
    this.prochaineVermifugation,
    this.traitementEnCours = false,
    this.maladie = "",
    this.finTraitement,
    required this.observations,
    this.recommandations = "",
    required this.statut,
  });

  InterventionModel copyWith({
    String? id,
    String? numero,
    String? clientId,
    String? clientNom,
    String? bergerieId,
    String? bergerieNom,
    String? origineIntervention,
    String? abonnementId,
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
    List<String>? moutonsConcernes,
    bool? vermifugation,
    String? produitVermifuge,
    DateTime? prochaineVermifugation,
    bool? traitementEnCours,
    String? maladie,
    DateTime? finTraitement,
    String? recommandations,
  }) {
    return InterventionModel(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      clientId: clientId ?? this.clientId,
      clientNom: clientNom ?? this.clientNom,
      bergerieId: bergerieId ?? this.bergerieId,
      bergerieNom: bergerieNom ?? this.bergerieNom,
      origineIntervention:
      origineIntervention ?? this.origineIntervention,
      abonnementId:
      abonnementId ?? this.abonnementId,
      dateIntervention:
      dateIntervention ?? this.dateIntervention,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      lavage: lavage ?? this.lavage,
      nettoyageBergerie:
      nettoyageBergerie ?? this.nettoyageBergerie,
      desinfection:
      desinfection ?? this.desinfection,
      agent: agent ?? this.agent,
      vehicule: vehicule ?? this.vehicule,
      nombreMoutons:
      nombreMoutons ?? this.nombreMoutons,
      moutonsConcernes:
      moutonsConcernes ?? this.moutonsConcernes,
      vermifugation:
      vermifugation ?? this.vermifugation,
      produitVermifuge:
      produitVermifuge ?? this.produitVermifuge,
      prochaineVermifugation:
      prochaineVermifugation ??
          this.prochaineVermifugation,
      traitementEnCours:
      traitementEnCours ??
          this.traitementEnCours,
      maladie: maladie ?? this.maladie,
      finTraitement:
      finTraitement ?? this.finTraitement,
      observations:
      observations ?? this.observations,
      recommandations:
      recommandations ?? this.recommandations,
      statut: statut ?? this.statut,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'clientId': clientId,
      'clientNom': clientNom,
      'bergerieId': bergerieId,
      'bergerieNom': bergerieNom,
      'origineIntervention': origineIntervention,
      'abonnementId': abonnementId,
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
      'moutonsConcernes': moutonsConcernes,
      'vermifugation': vermifugation,
      'produitVermifuge': produitVermifuge,
      'prochaineVermifugation':
      prochaineVermifugation?.toIso8601String(),
      'traitementEnCours': traitementEnCours,
      'maladie': maladie,
      'finTraitement':
      finTraitement?.toIso8601String(),
      'observations': observations,
      'recommandations': recommandations,
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
      bergerieId: map['bergerieId'] ?? '',
      bergerieNom: map['bergerieNom'] ?? '',
      origineIntervention:
      map['origineIntervention'] ?? 'Ponctuelle',
      abonnementId: map['abonnementId'],
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
      moutonsConcernes: List<String>.from(
        map['moutonsConcernes'] ?? [],
      ),
      vermifugation:
      map['vermifugation'] ?? false,
      produitVermifuge:
      map['produitVermifuge'] ?? '',
      prochaineVermifugation:
      map['prochaineVermifugation'] != null
          ? DateTime.parse(
        map['prochaineVermifugation'],
      )
          : null,
      traitementEnCours:
      map['traitementEnCours'] ?? false,
      maladie: map['maladie'] ?? '',
      finTraitement:
      map['finTraitement'] != null
          ? DateTime.parse(
        map['finTraitement'],
      )
          : null,
      observations: map['observations'] ?? '',
      recommandations:
      map['recommandations'] ?? '',
      statut: map['statut'] ?? '',
    );
  }
}