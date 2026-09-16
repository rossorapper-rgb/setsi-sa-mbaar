class CloudinaryConfig {
  CloudinaryConfig._();

  /// Nom public de l'environnement Cloudinary.
  static const String cloudName = 'k9qomkc1';

  /// Nom du preset d'upload unsigned créé dans Cloudinary.
  static const String uploadPreset = 'setsi_moutons';

  static bool get isConfigured =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;
}
