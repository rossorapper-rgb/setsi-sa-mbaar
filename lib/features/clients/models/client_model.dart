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

factory ClientModel.fromMap(
Map<String, dynamic> map,
String id,
) {
return ClientModel(
id: id,
nom: map["nom"] ?? "",
telephone: map["telephone"] ?? "",
quartier: map["quartier"] ?? "",
adresse: map["adresse"] ?? "",
nombreTroupeaux:
(map["nombreTroupeaux"] ?? 0) as int,
nombreMoutons:
(map["nombreMoutons"] ?? 0) as int,
abonnement:
map["abonnement"] ?? "",
actif: map["actif"] ?? true,
);
}

Map<String, dynamic> toMap() {
return {
"nom": nom,
"telephone": telephone,
"quartier": quartier,
"adresse": adresse,
"nombreTroupeaux": nombreTroupeaux,
"nombreMoutons": nombreMoutons,
"abonnement": abonnement,
"actif": actif,
};
}
ClientModel copyWith({
  String? id,
  String? nom,
  String? telephone,
  String? quartier,
  String? adresse,
  int? nombreTroupeaux,
  int? nombreMoutons,
  String? abonnement,
  bool? actif,
}) {
  return ClientModel(
    id: id ?? this.id,
    nom: nom ?? this.nom,
    telephone: telephone ?? this.telephone,
    quartier: quartier ?? this.quartier,
    adresse: adresse ?? this.adresse,
    nombreTroupeaux:
    nombreTroupeaux ?? this.nombreTroupeaux,
    nombreMoutons:
    nombreMoutons ?? this.nombreMoutons,
    abonnement:
    abonnement ?? this.abonnement,
    actif: actif ?? this.actif,
  );
}

@override
String toString() {
  return 'ClientModel('
      'id: $id, '
      'nom: $nom, '
      'telephone: $telephone, '
      'quartier: $quartier, '
      'adresse: $adresse, '
      'nombreTroupeaux: $nombreTroupeaux, '
      'nombreMoutons: $nombreMoutons, '
      'abonnement: $abonnement, '
      'actif: $actif'
      ')';
}

@override
bool operator ==(Object other) {
  if (identical(this, other)) return true;

  return other is ClientModel &&
      other.id == id &&
      other.nom == nom &&
      other.telephone == telephone &&
      other.quartier == quartier &&
      other.adresse == adresse &&
      other.nombreTroupeaux == nombreTroupeaux &&
      other.nombreMoutons == nombreMoutons &&
      other.abonnement == abonnement &&
      other.actif == actif;
}

@override
int get hashCode {
  return id.hashCode ^
  nom.hashCode ^
  telephone.hashCode ^
  quartier.hashCode ^
  adresse.hashCode ^
  nombreTroupeaux.hashCode ^
  nombreMoutons.hashCode ^
  abonnement.hashCode ^
  actif.hashCode;
}
}