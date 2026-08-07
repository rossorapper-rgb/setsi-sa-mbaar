import '../session/current_user_service.dart';

class PermissionService {
  PermissionService._();

  /// ===========================
  /// UTILISATEURS
  /// ===========================

  static bool canManageUsers() {
    return CurrentUserService.instance.isAdmin;
  }

  /// ===========================
  /// CLIENTS
  /// ===========================

  static bool canViewClients() {
    return CurrentUserService.instance.isAdmin ||
        CurrentUserService.instance.isResponsable;
  }

  static bool canCreateClient() {
    return CurrentUserService.instance.isAdmin ||
        CurrentUserService.instance.isResponsable;
  }

  static bool canEditClient() {
    return CurrentUserService.instance.isAdmin ||
        CurrentUserService.instance.isResponsable;
  }

  static bool canDeleteClient() {
    return CurrentUserService.instance.isAdmin;
  }

  /// ===========================
  /// BERGERIES
  /// ===========================

  static bool canViewBergeries() {
    return CurrentUserService.instance.isLoggedIn;
  }

  static bool canCreateBergerie() {
    return CurrentUserService.instance.isAdmin ||
        CurrentUserService.instance.isResponsable;
  }

  static bool canEditBergerie() {
    return CurrentUserService.instance.isAdmin ||
        CurrentUserService.instance.isResponsable;
  }

  static bool canDeleteBergerie() {
    return CurrentUserService.instance.isAdmin;
  }

  /// ===========================
  /// MOUTONS
  /// ===========================

  static bool canViewMoutons() {
    return CurrentUserService.instance.isLoggedIn;
  }

  static bool canCreateMouton() {
    return CurrentUserService.instance.isAdmin ||
        CurrentUserService.instance.isResponsable ||
        CurrentUserService.instance.isClient;
  }

  static bool canEditMouton() {
    return CurrentUserService.instance.isAdmin ||
        CurrentUserService.instance.isResponsable ||
        CurrentUserService.instance.isTechnicien;
  }

  static bool canDeleteMouton() {
    return CurrentUserService.instance.isAdmin;
  }

  /// ===========================
  /// GESTATIONS
  /// ===========================

  static bool canViewGestations() {
    return CurrentUserService.instance.isLoggedIn;
  }

  static bool canManageGestations() {
    return CurrentUserService.instance.isAdmin ||
        CurrentUserService.instance.isResponsable ||
        CurrentUserService.instance.isTechnicien;
  }

  /// ===========================
  /// INTERVENTIONS
  /// ===========================

  static bool canViewInterventions() {
    return CurrentUserService.instance.isLoggedIn;
  }

  static bool canCreateIntervention() {
    return CurrentUserService.instance.isAdmin ||
        CurrentUserService.instance.isResponsable;
  }

  static bool canExecuteIntervention() {
    return CurrentUserService.instance.isTechnicien;
  }

  /// ===========================
  /// FINANCES
  /// ===========================

  static bool canViewFinance() {
    return CurrentUserService.instance.isAdmin ||
        CurrentUserService.instance.isResponsable;
  }

  static bool canManageFinance() {
    return CurrentUserService.instance.isAdmin;
  }

  /// ===========================
  /// RAPPORTS
  /// ===========================

  static bool canViewReports() {
    return CurrentUserService.instance.isAdmin ||
        CurrentUserService.instance.isResponsable;
  }

  /// ===========================
  /// PARAMÈTRES
  /// ===========================

  static bool canManageSettings() {
    return CurrentUserService.instance.isAdmin;
  }
}