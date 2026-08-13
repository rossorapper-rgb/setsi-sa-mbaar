import 'package:flutter/material.dart';

import '../../../../core/session/current_user_service.dart';
import '../models/drawer_menu_item.dart';
import '../../../utilisateurs/models/user_role.dart';

class DrawerMenuService {
  DrawerMenuService._();

  static final DrawerMenuService instance =
  DrawerMenuService._();

  List<DrawerMenuItem> get menus {
    final role = CurrentUserService.instance.role;

    final items = <DrawerMenuItem>[
      // ==========================================================
      // TABLEAU DE BORD
      // ==========================================================

      DrawerMenuItem(
        icon: Icons.dashboard_rounded,
        title: "Tableau de bord",
        route: "/dashboard/admin",
        roles: UserRole.values,
      ),

      // ==========================================================
      // CLIENT
      // ==========================================================

      DrawerMenuItem(
        icon: Icons.pets_rounded,
        title: "Mes moutons",
        route: "/moutons",
        roles: const [
          UserRole.client,
        ],
      ),

      DrawerMenuItem(
        icon: Icons.favorite_rounded,
        title: "Mes gestations",
        route: "/gestations",
        roles: const [
          UserRole.client,
        ],
      ),

      // ==========================================================
      // CLIENT + ADMIN + RESPONSABLE + TECHNICIEN
      // ==========================================================

      DrawerMenuItem(
        icon: Icons.cleaning_services_rounded,
        title: "Interventions",
        route: "/interventions",
        roles: const [
          UserRole.admin,
          UserRole.responsable,
          UserRole.technicien,
          UserRole.client,
        ],
      ),

      // ==========================================================
      // ALLÔ VETO — TOUS LES RÔLES
      // ==========================================================

      DrawerMenuItem(
        icon: Icons.medical_services_rounded,
        title: "Allô Veto",
        route: "/allo-veto",
        roles: UserRole.values,
      ),

      // ==========================================================
      // ADMIN + RESPONSABLE
      // ==========================================================

      DrawerMenuItem(
        icon: Icons.people_alt_rounded,
        title: "Clients",
        route: "/clients",
        roles: const [
          UserRole.admin,
          UserRole.responsable,
        ],
      ),

      // ==========================================================
      // ADMIN
      // ==========================================================

      DrawerMenuItem(
        icon: Icons.manage_accounts_rounded,
        title: "Utilisateurs",
        route: "/utilisateurs",
        roles: const [
          UserRole.admin,
        ],
      ),

      // ==========================================================
      // ADMIN + RESPONSABLE + TECHNICIEN
      // ==========================================================

      DrawerMenuItem(
        icon: Icons.home_work_rounded,
        title: "Bergeries",
        route: "/bergeries",
        roles: const [
          UserRole.admin,
          UserRole.responsable,
          UserRole.technicien,
        ],
      ),

      // ==========================================================
      // ADMIN
      // ==========================================================

      DrawerMenuItem(
        icon: Icons.workspace_premium_rounded,
        title: "Abonnements",
        route: "/abonnements",
        roles: const [
          UserRole.admin,
        ],
      ),

      DrawerMenuItem(
        icon: Icons.payments_rounded,
        title: "Paiements",
        route: "/finances",
        roles: const [
          UserRole.admin,
        ],
      ),

      DrawerMenuItem(
        icon: Icons.bar_chart_rounded,
        title: "Rapports",
        route: "/rapports-financiers",
        roles: const [
          UserRole.admin,
          UserRole.responsable,
        ],
      ),

      DrawerMenuItem(
        icon: Icons.settings_rounded,
        title: "Paramètres",
        route: "/parametres",
        roles: const [
          UserRole.admin,
        ],
      ),
    ];

    if (role == null) {
      return [];
    }

    return items.where((item) => item.isAllowed(role)).toList();
  }
}
