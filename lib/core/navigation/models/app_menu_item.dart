import 'package:flutter/material.dart';

import '../../roles/user_role.dart';
import '../app_menu_key.dart';

class AppMenuItem {
  final AppMenuKey key;
  final IconData icon;
  final String title;
  final String route;
  final List<UserRole> roles;

  final List<AppMenuItem> children;

  final int? badgeCount;

  final bool visible;

  const AppMenuItem({
    required this.key,
    required this.icon,
    required this.title,
    required this.route,
    required this.roles,
    this.children = const [],
    this.badgeCount,
    this.visible = true,
  });

  bool get hasChildren => children.isNotEmpty;
}