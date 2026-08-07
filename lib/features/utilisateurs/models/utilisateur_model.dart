import 'user_role.dart';

class UtilisateurModel {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final String emailTechnique;
  final UserRole role;
  final String? bergerieId;
  final bool actif;
  final DateTime dateCreation;
  final DateTime? derniereConnexion;
  final String creePar;
  final String? photoUrl;
  final Map<String, bool> permissions;

  const UtilisateurModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.emailTechnique,
    required this.role,
    this.bergerieId,
    required this.actif,
    required this.dateCreation,
    this.derniereConnexion,
    required this.creePar,
    this.photoUrl,
    required this.permissions,
  });

  String get nomComplet => "$prenom $nom";

  String get statut => actif ? "Actif" : "Inactif";

  factory UtilisateurModel.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    return UtilisateurModel(
      id: id,
      nom: map["nom"] ?? "",
      prenom: map["prenom"] ?? "",
      telephone: map["telephone"] ?? "",
      emailTechnique: map["emailTechnique"] ?? "",
      role: UserRoleExtension.fromString(
        map["role"] ?? "client",
      ),
      bergerieId: map["bergerieId"],
      actif: map["actif"] ?? true,
      dateCreation: map["dateCreation"] is DateTime
          ? map["dateCreation"]
          : DateTime.tryParse(
        map["dateCreation"]?.toString() ?? "",
      ) ??
          DateTime.now(),
      derniereConnexion:
      map["derniereConnexion"] == null
          ? null
          : (map["derniereConnexion"] is DateTime
          ? map["derniereConnexion"]
          : DateTime.tryParse(
        map["derniereConnexion"].toString(),
      )),
      creePar: map["creePar"] ?? "",
      photoUrl: map["photoUrl"],
      permissions: Map<String, bool>.from(
        map["permissions"] ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "nom": nom,
      "prenom": prenom,
      "telephone": telephone,
      "emailTechnique": emailTechnique,
      "role": role.value,
      "bergerieId": bergerieId,
      "actif": actif,
      "dateCreation": dateCreation.toIso8601String(),
      "derniereConnexion":
      derniereConnexion?.toIso8601String(),
      "creePar": creePar,
      "photoUrl": photoUrl,
      "permissions": permissions,
    };
  }

  UtilisateurModel copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? telephone,
    String? emailTechnique,
    UserRole? role,
    String? bergerieId,
    bool? actif,
    DateTime? dateCreation,
    DateTime? derniereConnexion,
    String? creePar,
    String? photoUrl,
    Map<String, bool>? permissions,
  }) {
    return UtilisateurModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      emailTechnique:
      emailTechnique ?? this.emailTechnique,
      role: role ?? this.role,
      bergerieId: bergerieId ?? this.bergerieId,
      actif: actif ?? this.actif,
      dateCreation: dateCreation ?? this.dateCreation,
      derniereConnexion:
      derniereConnexion ?? this.derniereConnexion,
      creePar: creePar ?? this.creePar,
      photoUrl: photoUrl ?? this.photoUrl,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  String toString() {
    return "UtilisateurModel("
        "id: $id, "
        "nom: $nom, "
        "prenom: $prenom, "
        "telephone: $telephone, "
        "role: ${role.value}, "
        "bergerieId: $bergerieId, "
        "actif: $actif"
        ")";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UtilisateurModel &&
        other.id == id &&
        other.nom == nom &&
        other.prenom == prenom &&
        other.telephone == telephone &&
        other.emailTechnique == emailTechnique &&
        other.role == role &&
        other.bergerieId == bergerieId &&
        other.actif == actif;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    nom.hashCode ^
    prenom.hashCode ^
    telephone.hashCode ^
    emailTechnique.hashCode ^
    role.hashCode ^
    bergerieId.hashCode ^
    actif.hashCode;
  }
}