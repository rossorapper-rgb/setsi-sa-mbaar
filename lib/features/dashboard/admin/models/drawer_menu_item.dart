import 'package:flutter/material.dart';

import '../../../utilisateurs/models/user_role.dart';

class DrawerMenuItem {
  final IconData icon;
  final String title;
  final String route;
  final List<UserRole> roles;

  const DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.roles,
  });

  bool isAllowed(UserRole? role) {
    if (role == null) return false;
    return roles.contains(role);
  }
}