import 'package:flutter/material.dart';

/// Configuration personnalisée d'une application de bergerie.
///
/// Le même code source peut être utilisé pour plusieurs bergeries.
/// Seules les informations de cette configuration changent.
class BergerieConfig {
  final String bergerieId;

  /// Nom de la bergerie affiché dans l'application.
  final String nomBergerie;

  /// Nom affiché comme nom de l'application sur l'appareil.
  final String nomApplication;

  /// Chemin ou URL du logo de la bergerie.
  final String? logo;

  /// Couleur principale de l'application.
  final Color couleurPrimaire;

  /// Couleur secondaire / accent.
  final Color couleurSecondaire;

  /// Couleur de fond principale.
  final Color couleurFond;

  /// Slogan de la bergerie.
  final String? slogan;

  /// Téléphone de la bergerie.
  final String? telephone;

  /// Adresse de la bergerie.
  final String? adresse;

  /// Email de la bergerie.
  final String? email;

  /// Indique si cette configuration est active.
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

  /// Configuration par défaut utilisée pour SET'S I SA MBAAR.
  factory BergerieConfig.defaut() {
    return const BergerieConfig(
      bergerieId: 'setsi-sa-mbaar',
      nomBergerie: "SET'S I SA MBAAR",
      nomApplication: "SET'S I SA MBAAR",
      logo: null,
      couleurPrimaire: Color(0xFF123B63),
      couleurSecondaire: Color(0xFF2E9E5B),
      couleurFond: Colors.white,
      slogan: "Le partenaire de votre élevage",
      telephone: null,
      adresse: null,
      email: null,
      active: true,
    );
  }

  /// Exemple de configuration pour BERGERIE BARAKA.
  ///
  /// Cette configuration sert actuellement de référence pour
  /// tester notre système de personnalisation.
  factory BergerieConfig.baraka() {
    return const BergerieConfig(
      bergerieId: 'bergerie-baraka',
      nomBergerie: 'BERGERIE BARAKA',
      nomApplication: 'BERGERIE BARAKA',
      logo: 'assets/images/bergerie_baraka_logo.png',
      couleurPrimaire: Color(0xFF1565C0),
      couleurSecondaire: Color(0xFFF28C28),
      couleurFond: Colors.white,
      slogan: "Une meilleure gestion pour une meilleure bergerie",
      telephone: null,
      adresse: null,
      email: null,
      active: true,
    );
  }

  /// Crée une copie de la configuration avec certaines valeurs modifiées.
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
  }) {
    return BergerieConfig(
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
  }

  /// Conversion vers une Map.
  ///
  /// Utile lorsque la configuration sera enregistrée dans Firestore.
  Map<String, dynamic> toMap() {
    return {
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
  }

  /// Création d'une configuration à partir d'une Map Firestore.
  factory BergerieConfig.fromMap(Map<String, dynamic> map) {
    return BergerieConfig(
      bergerieId: map['bergerieId'] as String? ?? '',
      nomBergerie: map['nomBergerie'] as String? ?? '',
      nomApplication: map['nomApplication'] as String? ?? '',
      logo: map['logo'] as String?,
      couleurPrimaire: _colorFromMap(
        map['couleurPrimaire'],
        const Color(0xFF123B63),
      ),
      couleurSecondaire: _colorFromMap(
        map['couleurSecondaire'],
        const Color(0xFF2E9E5B),
      ),
      couleurFond: _colorFromMap(
        map['couleurFond'],
        Colors.white,
      ),
      slogan: map['slogan'] as String?,
      telephone: map['telephone'] as String?,
      adresse: map['adresse'] as String?,
      email: map['email'] as String?,
      active: map['active'] as bool? ?? true,
    );
  }

  static Color _colorFromMap(dynamic value, Color defaultColor) {
    if (value is int) {
      return Color(value);
    }

    if (value is String) {
      final hex = value.replaceFirst('#', '');

      try {
        final parsed = int.parse(
          hex.length == 6 ? 'FF$hex' : hex,
          radix: 16,
        );

        return Color(parsed);
      } catch (_) {
        return defaultColor;
      }
    }

    return defaultColor;
  }
}
