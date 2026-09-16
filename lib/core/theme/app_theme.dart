import 'package:flutter/material.dart';

import '../config/bergerie_config.dart';
import 'app_colors.dart';
import 'bergerie_theme.dart';

class AppTheme {
  AppTheme._();

  /// Thème historique de SET'S I SA MBAAR.
  ///
  /// Conservé pour éviter de casser les écrans existants pendant
  /// la migration vers le système de personnalisation par bergerie.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      colorSchemeSeed: AppColors.primary,

      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
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
    );
  }

  /// Thème construit à partir de la configuration d'une bergerie.
  static ThemeData lightThemeForBergerie(BergerieConfig config) {
    return BergerieTheme.lightTheme(config);
  }
}
