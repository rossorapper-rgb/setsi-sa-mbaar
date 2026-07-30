import 'package:cloud_firestore/cloud_firestore.dart';

class MiseBasModel {
  /// Identifiant Firestore
  final String id;

  /// Code métier
  final String code;

  /// Reproduction concernée
  final String reproductionId;

  /// Brebis concernée
  final String moutonId;

  /// Date de mise bas
  final DateTime dateMiseBas;

  /// Nombre total d'agneaux
  final int nombreAgneaux;

  /// Nombre de mâles
  final int nombreMales;

  /// Nombre de femelles
  final int nombreFemelles;

  /// Observations
  final String observations;

  /// Date de création
  final DateTime dateCreation;

  const MiseBasModel({
    required this.id,
    required this.code,
    required this.reproductionId,
    required this.moutonId,
    required this.dateMiseBas,
    required this.nombreAgneaux,
    required this.nombreMales,
    required this.nombreFemelles,
    required this.observations,
    required this.dateCreation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'reproductionId': reproductionId,
      'moutonId': moutonId,
      'dateMiseBas': Timestamp.fromDate(dateMiseBas),
      'nombreAgneaux': nombreAgneaux,
      'nombreMales': nombreMales,
      'nombreFemelles': nombreFemelles,
      'observations': observations,
      'dateCreation': Timestamp.fromDate(dateCreation),
    };
  }

  factory MiseBasModel.fromMap(Map<String, dynamic> map) {
    return MiseBasModel(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      reproductionId: map['reproductionId'] ?? '',
      moutonId: map['moutonId'] ?? '',
      dateMiseBas: (map['dateMiseBas'] as Timestamp).toDate(),
      nombreAgneaux: map['nombreAgneaux'] ?? 0,
      nombreMales: map['nombreMales'] ?? 0,
      nombreFemelles: map['nombreFemelles'] ?? 0,
      observations: map['observations'] ?? '',
      dateCreation: (map['dateCreation'] as Timestamp).toDate(),
    );
  }

  MiseBasModel copyWith({
    String? id,
    String? code,
    String? reproductionId,
    String? moutonId,
    DateTime? dateMiseBas,
    int? nombreAgneaux,
    int? nombreMales,
    int? nombreFemelles,
    String? observations,
    DateTime? dateCreation,
  }) {
    return MiseBasModel(
      id: id ?? this.id,
      code: code ?? this.code,
      reproductionId: reproductionId ?? this.reproductionId,
      moutonId: moutonId ?? this.moutonId,
      dateMiseBas: dateMiseBas ?? this.dateMiseBas,
      nombreAgneaux: nombreAgneaux ?? this.nombreAgneaux,
      nombreMales: nombreMales ?? this.nombreMales,
      nombreFemelles: nombreFemelles ?? this.nombreFemelles,
      observations: observations ?? this.observations,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}