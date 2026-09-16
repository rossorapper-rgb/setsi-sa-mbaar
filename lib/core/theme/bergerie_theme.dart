import 'package:flutter/material.dart';

import '../config/bergerie_config.dart';

/// Construit le thème visuel à partir de la configuration de la bergerie.
///
/// Le code de l'application reste identique pour toutes les bergeries.
/// Les couleurs et l'identité visuelle sont fournies par BergerieConfig.
class BergerieTheme {
  BergerieTheme._();

  static ThemeData lightTheme(BergerieConfig config) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: config.couleurPrimaire,
      primary: config.couleurPrimaire,
      secondary: config.couleurSecondaire,
      surface: Colors.white,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: config.couleurFond,

      appBarTheme: AppBarTheme(
        backgroundColor: config.couleurPrimaire,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.couleurPrimaire,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
