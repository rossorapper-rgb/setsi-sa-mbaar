import 'package:flutter/material.dart';

class BergerieConfig {
  final String bergerieId;
  final String nomBergerie;
  final String nomApplication;
  final String? logo;
  final Color couleurPrimaire;
  final Color couleurSecondaire;
  final Color couleurFond;
  final String? slogan;
  final String? telephone;
  final String? adresse;
  final String? email;
  final bool active;

  const BergerieConfig({
    required this.bergerieId,
    required this.nomBergerie,
    required this.nomApplication,
    this.logo,
    required this.couleurPrimaire,
    required this.couleurSecondaire,
    this.couleurFond = Colors.white,
    this.slogan,
    this.telephone,
    this.adresse,
    this.email,
    this.active = true,
  });

  factory BergerieConfig.defaut() => const BergerieConfig(
        bergerieId: 'setsi-sa-mbaar',
        nomBergerie: "SET'S I SA MBAAR",
        nomApplication: "SET'S I SA MBAAR",
        couleurPrimaire: Color(0xFF123B63),
        couleurSecondaire: Color(0xFF2E9E5B),
        slogan: 'Le partenaire de votre élevage',
      );

  factory BergerieConfig.baraka() => const BergerieConfig(
        bergerieId: '8e870f6d-1f3a-4ce8-b1d6-2dff3be364b3',
        nomBergerie: 'BERGERIE BARAKA',
        nomApplication: 'BERGERIE BARAKA',
        logo: 'assets/images/bergerie_baraka_logo.png',
        couleurPrimaire: Color(0xFF1597B7),
        couleurSecondaire: Color(0xFFF59A00),
        couleurFond: Colors.white,
        slogan: 'Une meilleure gestion pour une meilleure bergerie',
        active: true,
      );

  BergerieConfig copyWith({
    String? bergerieId,
    String? nomBergerie,
    String? nomApplication,
    String? logo,
    Color? couleurPrimaire,
    Color? couleurSecondaire,
    Color? couleurFond,
    String? slogan,
    String? telephone,
    String? adresse,
    String? email,
    bool? active,
  }) => BergerieConfig(
        bergerieId: bergerieId ?? this.bergerieId,
        nomBergerie: nomBergerie ?? this.nomBergerie,
        nomApplication: nomApplication ?? this.nomApplication,
        logo: logo ?? this.logo,
        couleurPrimaire: couleurPrimaire ?? this.couleurPrimaire,
        couleurSecondaire: couleurSecondaire ?? this.couleurSecondaire,
        couleurFond: couleurFond ?? this.couleurFond,
        slogan: slogan ?? this.slogan,
        telephone: telephone ?? this.telephone,
        adresse: adresse ?? this.adresse,
        email: email ?? this.email,
        active: active ?? this.active,
      );

  Map<String, dynamic> toMap() => {
        'bergerieId': bergerieId,
        'nomBergerie': nomBergerie,
        'nomApplication': nomApplication,
        'logo': logo,
        'couleurPrimaire': couleurPrimaire.value,
        'couleurSecondaire': couleurSecondaire.value,
        'couleurFond': couleurFond.value,
        'slogan': slogan,
        'telephone': telephone,
        'adresse': adresse,
        'email': email,
        'active': active,
      };

  factory BergerieConfig.fromMap(Map<String, dynamic> map) => BergerieConfig(
        bergerieId: map['bergerieId'] as String? ?? '',
        nomBergerie: map['nomBergerie'] as String? ?? '',
        nomApplication: map['nomApplication'] as String? ?? '',
        logo: map['logo'] as String?,
        couleurPrimaire: _colorFromMap(map['couleurPrimaire'], const Color(0xFF123B63)),
        couleurSecondaire: _colorFromMap(map['couleurSecondaire'], const Color(0xFF2E9E5B)),
        couleurFond: _colorFromMap(map['couleurFond'], Colors.white),
        slogan: map['slogan'] as String?,
        telephone: map['telephone'] as String?,
        adresse: map['adresse'] as String?,
        email: map['email'] as String?,
        active: map['active'] as bool? ?? true,
      );

  static Color _colorFromMap(dynamic value, Color fallback) {
    if (value is int) return Color(value);
    if (value is String) {
      final hex = value.replaceFirst('#', '');
      try {
        return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
      } catch (_) {}
    }
    return fallback;
  }
}
