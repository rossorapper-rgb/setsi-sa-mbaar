class MoutonModel {
final String id;
final String bergerieId;

final String nom;
final String numeroIdentification;

final String race;
final String sexe;

final DateTime? dateNaissance;

final double poids;

final String couleur;

final String photoUrl;

final bool actif;

final DateTime dateCreation;

const MoutonModel({
required this.id,
required this.bergerieId,
required this.nom,
required this.numeroIdentification,
required this.race,
required this.sexe,
required this.dateNaissance,
required this.poids,
required this.couleur,
required this.photoUrl,
required this.actif,
required this.dateCreation,
});

MoutonModel copyWith({
String? id,
String? bergerieId,
String? nom,
String? numeroIdentification,
String? race,
String? sexe,
DateTime? dateNaissance,
double? poids,
String? couleur,
String? photoUrl,
bool? actif,
DateTime? dateCreation,
}) {
return MoutonModel(
id: id ?? this.id,
bergerieId:
bergerieId ??
this.bergerieId,
nom: nom ?? this.nom,
numeroIdentification:
numeroIdentification ??
this.numeroIdentification,
race: race ?? this.race,
sexe: sexe ?? this.sexe,
dateNaissance:
dateNaissance ??
this.dateNaissance,
poids: poids ?? this.poids,
couleur:
couleur ?? this.couleur,
photoUrl:
photoUrl ?? this.photoUrl,
actif: actif ?? this.actif,
dateCreation:
dateCreation ??
this.dateCreation,
);
}

String get code =>
numeroIdentification;

int get ageEnMois {
if (dateNaissance == null) {
return 0;
}

final maintenant =
DateTime.now();

int mois =
(maintenant.year -
dateNaissance!.year) *
12 +
(maintenant.month -
dateNaissance!.month);

if (maintenant.day <
dateNaissance!.day) {
mois--;
}

return mois < 0 ? 0 : mois;
}

String get ageTexte {
final mois = ageEnMois;

if (mois < 12) {
return "$mois mois";
}

final annees = mois ~/ 12;
final reste = mois % 12;

if (reste == 0) {
return annees == 1
? "1 an"
: "$annees ans";
}

return annees == 1
? "1 an $reste mois"
: "$annees ans $reste mois";
}
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'bergerieId': bergerieId,
    'nom': nom,
    'numeroIdentification':
    numeroIdentification,
    'race': race,
    'sexe': sexe,
    'dateNaissance':
    dateNaissance
        ?.millisecondsSinceEpoch,
    'poids': poids,
    'couleur': couleur,
    'photoUrl': photoUrl,
    'actif': actif,
    'dateCreation':
    dateCreation
        .millisecondsSinceEpoch,
  };
}

factory MoutonModel.fromMap(
    Map<String, dynamic> map,
    ) {
  return MoutonModel(
    id: map['id'] ?? '',
    bergerieId:
    map['bergerieId'] ?? '',
    nom: map['nom'] ?? '',
    numeroIdentification:
    map['numeroIdentification'] ??
        '',
    race: map['race'] ?? '',
    sexe: map['sexe'] ?? '',
    dateNaissance:
    map['dateNaissance'] != null
        ? DateTime
        .fromMillisecondsSinceEpoch(
      map['dateNaissance'],
    )
        : null,
    poids:
    (map['poids'] ?? 0)
        .toDouble(),
    couleur:
    map['couleur'] ?? '',
    photoUrl:
    map['photoUrl'] ?? '',
    actif:
    map['actif'] ?? true,
    dateCreation:
    DateTime
        .fromMillisecondsSinceEpoch(
      map['dateCreation'],
    ),
  );
}
}