class VeterinaireModel {
  final String id;
  final String nom;
  final String telephone;
  final String region;
  final String specialite;
  final bool disponible;

  const VeterinaireModel({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.region,
    required this.specialite,
    required this.disponible,
  });

  factory VeterinaireModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return VeterinaireModel(
      id: map['id'] ?? '',
      nom: map['nom'] ?? '',
      telephone: map['telephone'] ?? '',
      region: map['region'] ?? '',
      specialite: map['specialite'] ?? '',
      disponible: map['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'telephone': telephone,
      'region': region,
      'specialite': specialite,
      'disponible': disponible,
    };
  }

  VeterinaireModel copyWith({
    String? id,
    String? nom,
    String? telephone,
    String? region,
    String? specialite,
    bool? disponible,
  }) {
    return VeterinaireModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      region: region ?? this.region,
      specialite: specialite ?? this.specialite,
      disponible: disponible ?? this.disponible,
    );
  }
}