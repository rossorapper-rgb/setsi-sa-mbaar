class ClientModel {
  final String id;
  final String nom;
  final String telephone;
  final String adresse;
  final String quartier;
  final String abonnement;
  final int nombreMoutons;
  final int nombreTroupeaux;
  final bool actif;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClientModel({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.adresse,
    required this.quartier,
    required this.abonnement,
    required this.nombreMoutons,
    required this.nombreTroupeaux,
    required this.actif,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientModel.fromMap(Map<String, dynamic> map, String id) {
    return ClientModel(
      id: id,
      nom: map['nom'] ?? '',
      telephone: map['telephone'] ?? '',
      adresse: map['adresse'] ?? '',
      quartier: map['quartier'] ?? '',
      abonnement: map['abonnement'] ?? '',
      nombreMoutons: map['nombreMoutons'] ?? 0,
      nombreTroupeaux: map['nombreTroupeaux'] ?? 0,
      actif: map['actif'] ?? true,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'telephone': telephone,
      'adresse': adresse,
      'quartier': quartier,
      'abonnement': abonnement,
      'nombreMoutons': nombreMoutons,
      'nombreTroupeaux': nombreTroupeaux,
      'actif': actif,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ClientModel copyWith({
    String? id,
    String? nom,
    String? telephone,
    String? adresse,
    String? quartier,
    String? abonnement,
    int? nombreMoutons,
    int? nombreTroupeaux,
    bool? actif,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      quartier: quartier ?? this.quartier,
      abonnement: abonnement ?? this.abonnement,
      nombreMoutons: nombreMoutons ?? this.nombreMoutons,
      nombreTroupeaux: nombreTroupeaux ?? this.nombreTroupeaux,
      actif: actif ?? this.actif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}