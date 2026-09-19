import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'bergerie_config.dart';

class PublicBergerieConfig {
  final String bergerieId;
  final String nomBergerie;
  final String nomApplication;
  final String? logo;
  final String? imageAccueil;
  final Color couleurPrimaire;
  final Color couleurSecondaire;
  final Color couleurFond;
  final String? slogan;
  final bool active;

  const PublicBergerieConfig({
    required this.bergerieId,
    required this.nomBergerie,
    required this.nomApplication,
    this.logo,
    this.imageAccueil,
    required this.couleurPrimaire,
    required this.couleurSecondaire,
    this.couleurFond = Colors.white,
    this.slogan,
    this.active = true,
  });

  factory PublicBergerieConfig.defaut() => const PublicBergerieConfig(
        bergerieId: 'setsi-sa-mbaar',
        nomBergerie: "SET'S I SA MBAAR",
        nomApplication: "SET'S I SA MBAAR",
        logo: 'assets/images/app_icon.png',
        couleurPrimaire: Color(0xFF1597B7),
        couleurSecondaire: Color(0xFFF59A00),
        couleurFond: Colors.white,
        slogan: 'Le partenaire de votre élevage',
        active: true,
      );

  factory PublicBergerieConfig.fromMap(Map<String, dynamic> map) {
    return PublicBergerieConfig(
      bergerieId: map['bergerieId'] as String? ?? '',
      nomBergerie: map['nomBergerie'] as String? ?? '',
      nomApplication: map['nomApplication'] as String? ?? '',
      logo: map['logo'] as String?,
      imageAccueil: map['imageAccueil'] as String?,
      couleurPrimaire:
          _colorFromMap(map['couleurPrimaire'], const Color(0xFF1597B7)),
      couleurSecondaire:
          _colorFromMap(map['couleurSecondaire'], const Color(0xFFF59A00)),
      couleurFond: _colorFromMap(map['couleurFond'], Colors.white),
      slogan: map['slogan'] as String?,
      active: map['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'bergerieId': bergerieId,
        'nomBergerie': nomBergerie,
        'nomApplication': nomApplication,
        'logo': logo,
        'imageAccueil': imageAccueil,
        'couleurPrimaire': couleurPrimaire.value,
        'couleurSecondaire': couleurSecondaire.value,
        'couleurFond': couleurFond.value,
        'slogan': slogan,
        'active': active,
      };

  factory PublicBergerieConfig.fromBergerieConfig(BergerieConfig config) {
    return PublicBergerieConfig(
      bergerieId: config.bergerieId,
      nomBergerie: config.nomBergerie,
      nomApplication: config.nomApplication,
      logo: config.logo,
      imageAccueil: config.imageAccueil,
      couleurPrimaire: config.couleurPrimaire,
      couleurSecondaire: config.couleurSecondaire,
      couleurFond: config.couleurFond,
      slogan: config.slogan,
      active: config.active,
    );
  }

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

class PublicBergerieConfigService {
  PublicBergerieConfigService._();

  static final PublicBergerieConfigService instance =
      PublicBergerieConfigService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<PublicBergerieConfig> load(String? bergerieId) async {
    final id = bergerieId?.trim();

    if (id == null || id.isEmpty) {
      return PublicBergerieConfig.defaut();
    }

    final snapshot = await _firestore
        .collection('bergerie_public_config')
        .doc(id)
        .get(const GetOptions(source: Source.server));

    if (!snapshot.exists || snapshot.data() == null) {
      return id == PublicBergerieConfig.defaut().bergerieId
          ? PublicBergerieConfig.defaut()
          : PublicBergerieConfig(
              bergerieId: id,
              nomBergerie: 'BERGERIE',
              nomApplication: 'SET\'SI',
              couleurPrimaire: const Color(0xFF1597B7),
              couleurSecondaire: const Color(0xFFF59A00),
              couleurFond: Colors.white,
              slogan: 'Votre espace de gestion',
            );
    }

    return PublicBergerieConfig.fromMap(snapshot.data()!);
  }

  Future<void> save(BergerieConfig config) async {
    final publicConfig = PublicBergerieConfig.fromBergerieConfig(config);

    await _firestore
        .collection('bergerie_public_config')
        .doc(config.bergerieId)
        .set(publicConfig.toMap());
  }
}
