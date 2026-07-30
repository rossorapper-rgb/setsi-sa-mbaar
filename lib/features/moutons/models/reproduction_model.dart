enum ReproductionStatut {
  saillie,
  gestation,
  miseBas,
  terminee,
}

class ReproductionModel {
final String id;
final String code;

final String moutonId;

final DateTime dateSaillie;

final String belierId;
final String nomBelier;
final String raceBelier;
final String proprietaireBelier;

final DateTime datePrevueMiseBas;
final DateTime? dateMiseBas;

final int nombreAgneaux;
final int nombreMales;
final int nombreFemelles;

final String observations;

final ReproductionStatut
statut;

final DateTime dateCreation;
final DateTime? dateModification;

const ReproductionModel({
required this.id,
required this.code,
required this.moutonId,
required this.dateSaillie,
required this.belierId,
required this.nomBelier,
required this.raceBelier,
required this.proprietaireBelier,
required this.datePrevueMiseBas,
this.dateMiseBas,
this.nombreAgneaux = 0,
this.nombreMales = 0,
this.nombreFemelles = 0,
this.observations = "",
this.statut =
ReproductionStatut.saillie,
required this.dateCreation,
this.dateModification,
});

int get joursGestation {
return DateTime.now()
.difference(dateSaillie)
.inDays;
}

int get dureeGestation => 150;

int get joursRestants {
final reste =
dureeGestation -
joursGestation;

return reste < 0 ? 0 : reste;
}

double get progression {
final valeur =
joursGestation /
dureeGestation;

if (valeur < 0) {
return 0;
}

if (valeur > 1) {
return 1;
}

return valeur;
}

bool get miseBasPrevueAujourdHui =>
joursRestants == 0 &&
statut ==
ReproductionStatut
.gestation;

bool get enRetard =>
joursGestation >
dureeGestation &&
statut ==
ReproductionStatut
.gestation;
Map<String, dynamic> toMap() {
return {
"id": id,
"code": code,
"moutonId": moutonId,
"dateSaillie":
dateSaillie.toIso8601String(),
"belierId": belierId,
"nomBelier": nomBelier,
"raceBelier": raceBelier,
"proprietaireBelier":
proprietaireBelier,
"datePrevueMiseBas":
datePrevueMiseBas
.toIso8601String(),
"dateMiseBas":
dateMiseBas
?.toIso8601String(),
"nombreAgneaux":
nombreAgneaux,
"nombreMales":
nombreMales,
"nombreFemelles":
nombreFemelles,
"observations":
observations,
"statut": statut.name,
"dateCreation":
dateCreation
.toIso8601String(),
"dateModification":
dateModification
?.toIso8601String(),
};
}

factory ReproductionModel.fromMap(
Map<String, dynamic> map,
) {
return ReproductionModel(
id: map["id"] ?? "",
code: map["code"] ?? "",
moutonId:
map["moutonId"] ?? "",
dateSaillie:
DateTime.parse(
map["dateSaillie"],
),
belierId:
map["belierId"] ?? "",
nomBelier:
map["nomBelier"] ?? "",
raceBelier:
map["raceBelier"] ?? "",
proprietaireBelier:
map["proprietaireBelier"] ??
"",
datePrevueMiseBas:
DateTime.parse(
map["datePrevueMiseBas"],
),
dateMiseBas:
map["dateMiseBas"] != null
? DateTime.parse(
map["dateMiseBas"],
)
: null,
nombreAgneaux:
map["nombreAgneaux"] ?? 0,
nombreMales:
map["nombreMales"] ?? 0,
nombreFemelles:
map["nombreFemelles"] ?? 0,
observations:
map["observations"] ?? "",
statut:
ReproductionStatut.values
.firstWhere(
(e) =>
e.name ==
map["statut"],
orElse: () =>
ReproductionStatut
.saillie,
),
dateCreation:
DateTime.parse(
map["dateCreation"],
),
dateModification:
map["dateModification"] !=
null
? DateTime.parse(
map[
"dateModification"],
)
: null,
);
}
ReproductionModel copyWith({
  String? id,
  String? code,
  String? moutonId,
  DateTime? dateSaillie,
  String? belierId,
  String? nomBelier,
  String? raceBelier,
  String? proprietaireBelier,
  DateTime? datePrevueMiseBas,
  DateTime? dateMiseBas,
  int? nombreAgneaux,
  int? nombreMales,
  int? nombreFemelles,
  String? observations,
  ReproductionStatut? statut,
  DateTime? dateCreation,
  DateTime? dateModification,
}) {
  return ReproductionModel(
    id: id ?? this.id,
    code: code ?? this.code,
    moutonId: moutonId ?? this.moutonId,
    dateSaillie:
    dateSaillie ?? this.dateSaillie,
    belierId: belierId ?? this.belierId,
    nomBelier:
    nomBelier ?? this.nomBelier,
    raceBelier:
    raceBelier ?? this.raceBelier,
    proprietaireBelier:
    proprietaireBelier ??
        this.proprietaireBelier,
    datePrevueMiseBas:
    datePrevueMiseBas ??
        this.datePrevueMiseBas,
    dateMiseBas:
    dateMiseBas ?? this.dateMiseBas,
    nombreAgneaux:
    nombreAgneaux ??
        this.nombreAgneaux,
    nombreMales:
    nombreMales ??
        this.nombreMales,
    nombreFemelles:
    nombreFemelles ??
        this.nombreFemelles,
    observations:
    observations ??
        this.observations,
    statut: statut ?? this.statut,
    dateCreation:
    dateCreation ??
        this.dateCreation,
    dateModification:
    dateModification ??
        this.dateModification,
  );
}
}