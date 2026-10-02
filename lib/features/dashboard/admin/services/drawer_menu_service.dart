import 'package:flutter/material.dart';

import '../../../../core/session/current_user_service.dart';
import '../models/drawer_menu_item.dart';
import '../../../utilisateurs/models/user_role.dart';

class DrawerMenuService {
  DrawerMenuService._();

  static final DrawerMenuService instance = DrawerMenuService._();

  List<DrawerMenuItem> get menus {
    if (CurrentUserService.instance.role != UserRole.admin) {
      return [];
    }

    return const [
      DrawerMenuItem(icon: Icons.dashboard_rounded, title: "Tableau de bord", route: "/dashboard/admin", roles: [UserRole.admin]),
      DrawerMenuItem(icon: Icons.people_alt_rounded, title: "Clients", route: "/clients", roles: [UserRole.admin]),
      DrawerMenuItem(icon: Icons.home_work_rounded, title: "Bergeries", route: "/bergeries", roles: [UserRole.admin]),
    ];
  }
}
