class VeterinaireModel {
  final String id;
  final String bergerieId;
  final String nom;
  final String telephone;

  const VeterinaireModel({
    required this.id,
    required this.bergerieId,
    required this.nom,
    required this.telephone,
  });

  factory VeterinaireModel.fromMap(Map<String, dynamic> map) {
    return VeterinaireModel(
      id: map['id'] ?? '',
      bergerieId: map['bergerieId'] ?? '',
      nom: map['nom'] ?? '',
      telephone: map['telephone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bergerieId': bergerieId,
      'nom': nom,
      'telephone': telephone,
    };
  }

  VeterinaireModel copyWith({
    String? id,
    String? bergerieId,
    String? nom,
    String? telephone,
  }) {
    return VeterinaireModel(
      id: id ?? this.id,
      bergerieId: bergerieId ?? this.bergerieId,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
    );
  }
}