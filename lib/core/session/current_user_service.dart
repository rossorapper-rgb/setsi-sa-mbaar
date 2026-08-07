import '../../features/utilisateurs/models/utilisateur_model.dart';
import '../../features/utilisateurs/models/user_role.dart';

class CurrentUserService {
  CurrentUserService._();

  static final CurrentUserService instance =
  CurrentUserService._();

  UtilisateurModel? _currentUser;

  /// Utilisateur actuellement connecté
  UtilisateurModel? get currentUser => _currentUser;

  /// Définir l'utilisateur connecté
  void setCurrentUser(UtilisateurModel utilisateur) {
    _currentUser = utilisateur;
  }

  /// Effacer la session
  void clear() {
    _currentUser = null;
  }

  /// Vérifie si une session est ouverte
  bool get isLoggedIn => _currentUser != null;

  /// UID
  String? get uid => _currentUser?.id;

  /// Nom complet
  String get nomComplet =>
      _currentUser?.nomComplet ?? "";

  /// Téléphone
  String get telephone =>
      _currentUser?.telephone ?? "";

  /// Email technique
  String get emailTechnique =>
      _currentUser?.emailTechnique ?? "";

  /// Bergerie associée
  String? get bergerieId =>
      _currentUser?.bergerieId;

  /// Rôle
  UserRole? get role => _currentUser?.role;

  /// Permissions
  Map<String, bool> get permissions =>
      _currentUser?.permissions ?? {};

  /// Statut
  bool get actif =>
      _currentUser?.actif ?? false;

  /// Vérifications des rôles

  bool get isAdmin =>
      role == UserRole.admin;

  bool get isResponsable =>
      role == UserRole.responsable;

  bool get isTechnicien =>
      role == UserRole.technicien;

  bool get isClient =>
      role == UserRole.client;

  /// Vérifie une permission
  bool hasPermission(String permission) {
    return permissions[permission] ?? false;
  }
}