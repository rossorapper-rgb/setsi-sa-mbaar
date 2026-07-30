import 'package:cloud_firestore/cloud_firestore.dart';
class BergerieModel {
  final String id;
  final String clientId;

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

  BergerieModel copyWith({
    String? id,
    String? clientId,
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
    return BergerieModel(
      id: map['id'] ?? '',
      clientId: map['clientId'] ?? '',
      nom: map['nom'] ?? '',
      adresse: map['adresse'] ?? '',
      telephone: map['telephone'] ?? '',
      responsable: map['responsable'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      observations: map['observations'] ?? '',
      active: map['active'] ?? true,
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
