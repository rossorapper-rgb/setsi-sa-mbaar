enum UserRole {
  admin,
  responsable,
  technicien,
  client,
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return "Administrateur";

      case UserRole.responsable:
        return "Responsable";

      case UserRole.technicien:
        return "Technicien";

      case UserRole.client:
        return "Client";
    }
  }

  String get value {
    switch (this) {
      case UserRole.admin:
        return "admin";

      case UserRole.responsable:
        return "responsable";

      case UserRole.technicien:
        return "technicien";

      case UserRole.client:
        return "client";
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case "admin":
        return UserRole.admin;

      case "responsable":
        return UserRole.responsable;

      case "technicien":
        return UserRole.technicien;

      case "client":
        return UserRole.client;

      default:
        return UserRole.client;
    }
  }
}
