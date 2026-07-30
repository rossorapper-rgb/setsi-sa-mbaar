import 'package:cloud_firestore/cloud_firestore.dart';

class GestationModel {
final String id;

/// Femelle gestante
final String brebisId;
final String nomFemelle;

/// Bélier
final String? belierId;
final String belierNom;
final bool belierExterieur;
final String? proprietaireBelier;

/// Bergerie
final String bergerieId;

/// Dates
final DateTime dateSaillie;
final DateTime dateProbableMiseBas;
final DateTime? dateMiseBas;

/// Informations
final String typeSaillie;
final String statut;

/// Résultats
final int nombreAgneaux;
final int nombreMales;
final int nombreFemelles;
final int nombreMortNes;

/// Observations
final String observations;

/// Divers
final bool active;
final DateTime dateCreation;
final DateTime? dateModification;

const GestationModel({
required this.id,
required this.brebisId,
required this.nomFemelle,
this.belierId,
required this.belierNom,
this.belierExterieur = false,
this.proprietaireBelier,
required this.bergerieId,
required this.dateSaillie,
required this.dateProbableMiseBas,
this.dateMiseBas,
required this.typeSaillie,
this.statut = 'En cours',
this.nombreAgneaux = 0,
this.nombreMales = 0,
this.nombreFemelles = 0,
this.nombreMortNes = 0,
this.observations = '',
this.active = true,
required this.dateCreation,
this.dateModification,
});

GestationModel copyWith({
String? id,
String? brebisId,
String? nomFemelle,
String? belierId,
String? belierNom,
bool? belierExterieur,
String? proprietaireBelier,
String? bergerieId,
DateTime? dateSaillie,
DateTime? dateProbableMiseBas,
DateTime? dateMiseBas,
String? typeSaillie,
String? statut,
int? nombreAgneaux,
int? nombreMales,
int? nombreFemelles,
int? nombreMortNes,
String? observations,
bool? active,
DateTime? dateCreation,
DateTime? dateModification,
}) {
return GestationModel(
id: id ?? this.id,
brebisId: brebisId ?? this.brebisId,
nomFemelle: nomFemelle ?? this.nomFemelle,
belierId: belierId ?? this.belierId,
belierNom: belierNom ?? this.belierNom,
belierExterieur:
belierExterieur ?? this.belierExterieur,
proprietaireBelier:
proprietaireBelier ?? this.proprietaireBelier,
bergerieId: bergerieId ?? this.bergerieId,
dateSaillie:
dateSaillie ?? this.dateSaillie,
dateProbableMiseBas:
dateProbableMiseBas ??
this.dateProbableMiseBas,
dateMiseBas:
dateMiseBas ?? this.dateMiseBas,
typeSaillie:
typeSaillie ?? this.typeSaillie,
statut: statut ?? this.statut,
nombreAgneaux:
nombreAgneaux ?? this.nombreAgneaux,
nombreMales:
nombreMales ?? this.nombreMales,
nombreFemelles:
nombreFemelles ?? this.nombreFemelles,
nombreMortNes:
nombreMortNes ?? this.nombreMortNes,
observations:
observations ?? this.observations,
active: active ?? this.active,
dateCreation:
dateCreation ?? this.dateCreation,
dateModification:
dateModification ??
this.dateModification,
);
}
Map<String, dynamic> toMap() {
return {
'brebisId': brebisId,
'nomFemelle': nomFemelle,
'belierId': belierId,
'belierNom': belierNom,
'belierExterieur': belierExterieur,
'proprietaireBelier': proprietaireBelier,
'bergerieId': bergerieId,
'dateSaillie': Timestamp.fromDate(dateSaillie),
'dateProbableMiseBas':
Timestamp.fromDate(dateProbableMiseBas),
'dateMiseBas': dateMiseBas == null
? null
: Timestamp.fromDate(dateMiseBas!),
'typeSaillie': typeSaillie,
'statut': statut,
'nombreAgneaux': nombreAgneaux,
'nombreMales': nombreMales,
'nombreFemelles': nombreFemelles,
'nombreMortNes': nombreMortNes,
'observations': observations,
'active': active,
'dateCreation': Timestamp.fromDate(dateCreation),
'dateModification': dateModification == null
? null
: Timestamp.fromDate(dateModification!),
};
}

factory GestationModel.fromMap(
Map<String, dynamic> map,
String id,
) {
DateTime parseDate(dynamic value) {
if (value == null) return DateTime.now();

if (value is DateTime) {
return value;
}

if (value is Timestamp) {
return value.toDate();
}

if (value is String) {
return DateTime.parse(value);
}

return DateTime.now();
}

DateTime? parseNullableDate(dynamic value) {
if (value == null) return null;

if (value is DateTime) {
return value;
}

if (value is Timestamp) {
return value.toDate();
}

if (value is String) {
return DateTime.parse(value);
}

return null;
}

return GestationModel(
id: id,
brebisId: map['brebisId'] ?? '',
nomFemelle: map['nomFemelle'] ?? '',
belierId: map['belierId'],
belierNom: map['belierNom'] ?? '',
belierExterieur:
map['belierExterieur'] ?? false,
proprietaireBelier:
map['proprietaireBelier'],
bergerieId: map['bergerieId'] ?? '',
dateSaillie:
parseDate(map['dateSaillie']),
dateProbableMiseBas:
parseDate(map['dateProbableMiseBas']),
dateMiseBas:
parseNullableDate(map['dateMiseBas']),
typeSaillie: map['typeSaillie'] ?? '',
statut: map['statut'] ?? 'En cours',
nombreAgneaux:
map['nombreAgneaux'] ?? 0,
nombreMales:
map['nombreMales'] ?? 0,
nombreFemelles:
map['nombreFemelles'] ?? 0,
nombreMortNes:
map['nombreMortNes'] ?? 0,
observations:
map['observations'] ?? '',
active:
map['active'] ?? true,
dateCreation:
parseDate(map['dateCreation']),
dateModification:
parseNullableDate(
map['dateModification']),
);
}
/// Alias de compatibilité
String get moutonId => brebisId;

String get nomBelier => belierNom;

DateTime get dateMiseBasPrevue => dateProbableMiseBas;

int get nombrePetits => nombreAgneaux;

int get males => nombreMales;

int get femelles => nombreFemelles;

/// État
bool get estEnCours => statut == 'En cours';

bool get terminee => statut == 'Terminée';

bool get annulee => statut == 'Annulée';

/// Nombre de jours depuis la saillie
int get joursGestation =>
    DateTime.now().difference(dateSaillie).inDays;

/// Alias utilisé dans certains widgets
int get dureeGestation => joursGestation;

/// Nombre de jours restants avant la mise bas prévue
int get joursRestants =>
    dateProbableMiseBas.difference(DateTime.now()).inDays;

/// Progression de la gestation (150 jours)
double get progression {
  const int dureeNormale = 150;

  final p = joursGestation / dureeNormale;

  if (p < 0) return 0;

  if (p > 1) return 1;

  return p;
}

bool get miseBasEffectuee => dateMiseBas != null;

bool get estEnRetard =>
    !miseBasEffectuee &&
        DateTime.now().isAfter(dateProbableMiseBas);

bool get procheDeLaMiseBas =>
    !miseBasEffectuee &&
        joursRestants >= 0 &&
        joursRestants <= 15;
}
