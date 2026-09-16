class CloudinaryConfig {
  CloudinaryConfig._();

  /// Nom public de l'environnement Cloudinary.
  /// À renseigner après création du compte Cloudinary.
  static const String cloudName = '';

  /// Nom du preset d'upload unsigned créé dans Cloudinary.
  /// À renseigner après création du preset.
  static const String uploadPreset = '';

  static bool get isConfigured =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;
}
