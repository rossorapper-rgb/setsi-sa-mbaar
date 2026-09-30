import 'package:cloud_firestore/cloud_firestore.dart';

class BergerieModel {
  final String id;
  final String clientId;
  final String? slug;

  final String nom;
  final String adresse;
  final String telephone;
  final String responsable;

  final double? latitude;
  final double? longitude;

  final String observations;

  final bool active;

  final DateTime dateCreation;
  final DateTime? dateModification;

  const BergerieModel({
    required this.id,
    required this.clientId,
    this.slug,
    required this.nom,
    required this.adresse,
    required this.telephone,
    required this.responsable,
    this.latitude,
    this.longitude,
    this.observations = '',
    this.active = true,
    required this.dateCreation,
    this.dateModification,
  });

  String get slugEffectif => slug?.trim().isNotEmpty == true
      ? slug!.trim()
      : slugifier(nom);

  static String slugifier(String value) {
    var result = value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r"[àáâãäå]"), 'a')
        .replaceAll(RegExp(r"[èéêë]"), 'e')
        .replaceAll(RegExp(r"[ìíîï]"), 'i')
        .replaceAll(RegExp(r"[òóôõö]"), 'o')
        .replaceAll(RegExp(r"[ùúûü]"), 'u')
        .replaceAll(RegExp(r"[ç]"), 'c')
        .replaceAll(RegExp(r"[^a-z0-9]+"), '-')
        .replaceAll(RegExp(r"-+"), '-');
    result = result.replaceAll(RegExp(r"^-|-$"), '');
    return result.isEmpty ? 'bergerie' : result;
  }

  BergerieModel copyWith({
    String? id,
    String? clientId,
    String? slug,
    String? nom,
    String? adresse,
    String? telephone,
    String? responsable,
    double? latitude,
    double? longitude,
    String? observations,
    bool? active,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return BergerieModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      slug: slug ?? this.slug,
      nom: nom ?? this.nom,
      adresse: adresse ?? this.adresse,
      telephone: telephone ?? this.telephone,
      responsable: responsable ?? this.responsable,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      observations: observations ?? this.observations,
      active: active ?? this.active,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'slug': slugEffectif,
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'responsable': responsable,
      'latitude': latitude,
      'longitude': longitude,
      'observations': observations,
      'active': active,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification?.toIso8601String(),
    };
  }

  factory BergerieModel.fromMap(Map<String, dynamic> map) {
    final nom = map['nom']?.toString() ?? '';

    return BergerieModel(
      id: map['id']?.toString() ?? '',
      clientId: map['clientId']?.toString() ?? '',
      slug: map['slug']?.toString().trim().isNotEmpty == true
          ? map['slug'].toString().trim()
          : slugifier(nom),
      nom: nom,
      adresse: map['adresse']?.toString() ?? '',
      telephone: map['telephone']?.toString() ?? '',
      responsable: map['responsable']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      observations: map['observations']?.toString() ?? '',
      active: map['active'] as bool? ?? true,
      dateCreation: map['dateCreation'] is String
          ? DateTime.parse(map['dateCreation'])
          : (map['dateCreation'] as Timestamp).toDate(),
      dateModification: map['dateModification'] == null
          ? null
          : map['dateModification'] is String
              ? DateTime.parse(map['dateModification'])
              : (map['dateModification'] as Timestamp).toDate(),
    );
  }
}
