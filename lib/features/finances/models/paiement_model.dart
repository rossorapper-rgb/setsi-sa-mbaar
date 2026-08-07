enum ModePaiement {
  especes,
  wave,
  orangeMoney,
  virement,
  cheque,
}

enum TypePrestation {
  abonnement,
  lavage,
  nettoyageBergerie,
  desinfection,
  traitementVeterinaire,
  pedicure,
  preparationTabaski,
  autre,
}

class PaiementModel {
  final String id;
  final String numeroFacture;

  // Client
  final String clientId;
  final String clientNom;

  // Bergerie
  final String bergerieId;
  final String bergerieNom;

  // Intervention (optionnelle)
  final String? interventionId;

  // Facturation
  final TypePrestation typePrestation;
  final String abonnement;

  final double montantConseille;
  final double montantFacture;
  final double montantPaye;

  // Paiement
  final ModePaiement modePaiement;

  // Informations
  final String reference;
  final String motifRemise;
  final String observations;

  // Gestion
  final bool actif;
  final String creePar;

  // Dates
  final DateTime datePaiement;
  final DateTime dateCreation;
  final DateTime dateModification;

  const PaiementModel({
    required this.id,
    required this.numeroFacture,
    required this.clientId,
    required this.clientNom,
    required this.bergerieId,
    required this.bergerieNom,
    this.interventionId,
    required this.typePrestation,
    this.abonnement = "",
    required this.montantConseille,
    required this.montantFacture,
    required this.montantPaye,
    required this.modePaiement,
    this.reference = "",
    this.motifRemise = "",
    this.observations = "",
    this.actif = true,
    required this.creePar,
    required this.datePaiement,
    required this.dateCreation,
    required this.dateModification,
  });

  double get resteAPayer {
    final reste = montantFacture - montantPaye;
    return reste < 0 ? 0 : reste;
  }

  String get statut {
    if (montantPaye <= 0) {
      return "Impayé";
    }

    if (montantPaye < montantFacture) {
      return "Partiel";
    }

    return "Payé";
  }

  PaiementModel copyWith({
    String? id,
    String? numeroFacture,
    String? clientId,
    String? clientNom,
    String? bergerieId,
    String? bergerieNom,
    String? interventionId,
    TypePrestation? typePrestation,
    String? abonnement,
    double? montantConseille,
    double? montantFacture,
    double? montantPaye,
    ModePaiement? modePaiement,
    String? reference,
    String? motifRemise,
    String? observations,
    bool? actif,
    String? creePar,
    DateTime? datePaiement,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return PaiementModel(
      id: id ?? this.id,
      numeroFacture: numeroFacture ?? this.numeroFacture,
      clientId: clientId ?? this.clientId,
      clientNom: clientNom ?? this.clientNom,
      bergerieId: bergerieId ?? this.bergerieId,
      bergerieNom: bergerieNom ?? this.bergerieNom,
      interventionId: interventionId ?? this.interventionId,
      typePrestation: typePrestation ?? this.typePrestation,
      abonnement: abonnement ?? this.abonnement,
      montantConseille: montantConseille ?? this.montantConseille,
      montantFacture: montantFacture ?? this.montantFacture,
      montantPaye: montantPaye ?? this.montantPaye,
      modePaiement: modePaiement ?? this.modePaiement,
      reference: reference ?? this.reference,
      motifRemise: motifRemise ?? this.motifRemise,
      observations: observations ?? this.observations,
      actif: actif ?? this.actif,
      creePar: creePar ?? this.creePar,
      datePaiement: datePaiement ?? this.datePaiement,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification:
      dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroFacture': numeroFacture,
      'clientId': clientId,
      'clientNom': clientNom,
      'bergerieId': bergerieId,
      'bergerieNom': bergerieNom,
      'interventionId': interventionId,
      'typePrestation': typePrestation.name,
      'abonnement': abonnement,
      'montantConseille': montantConseille,
      'montantFacture': montantFacture,
      'montantPaye': montantPaye,
      'modePaiement': modePaiement.name,
      'reference': reference,
      'motifRemise': motifRemise,
      'observations': observations,
      'actif': actif,
      'creePar': creePar,
      'datePaiement': datePaiement.toIso8601String(),
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification':
      dateModification.toIso8601String(),
    };
  }

  factory PaiementModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return PaiementModel(
      id: map['id'] ?? '',
      numeroFacture: map['numeroFacture'] ?? '',
      clientId: map['clientId'] ?? '',
      clientNom: map['clientNom'] ?? '',
      bergerieId: map['bergerieId'] ?? '',
      bergerieNom: map['bergerieNom'] ?? '',
      interventionId: map['interventionId'],
      typePrestation: TypePrestation.values.firstWhere(
            (e) => e.name == map['typePrestation'],
        orElse: () => TypePrestation.autre,
      ),
      abonnement: map['abonnement'] ?? '',
      montantConseille:
      (map['montantConseille'] ?? 0).toDouble(),
      montantFacture:
      (map['montantFacture'] ?? 0).toDouble(),
      montantPaye:
      (map['montantPaye'] ?? 0).toDouble(),
      modePaiement: ModePaiement.values.firstWhere(
            (e) => e.name == map['modePaiement'],
        orElse: () => ModePaiement.especes,
      ),
      reference: map['reference'] ?? '',
      motifRemise: map['motifRemise'] ?? '',
      observations: map['observations'] ?? '',
      actif: map['actif'] ?? true,
      creePar: map['creePar'] ?? '',
      datePaiement: DateTime.parse(
        map['datePaiement'],
      ),
      dateCreation: DateTime.parse(
        map['dateCreation'],
      ),
      dateModification: DateTime.parse(
        map['dateModification'],
      ),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory PaiementModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PaiementModel.fromMap(json);
  }
}