import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Titres principaux
  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  // Texte courant
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );

  // Boutons
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // ==========================
  // Styles Dashboard
  // ==========================

  static const TextStyle cardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.subtitle,
  );

  static const TextStyle cardValue = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 13,
    color: AppColors.subtitle,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    color: AppColors.subtitle,
  );
}