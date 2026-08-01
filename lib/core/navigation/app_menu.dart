import 'package:flutter/material.dart';

import '../roles/user_role.dart';
import 'app_menu_key.dart';
import 'models/app_menu_item.dart';

class AppMenu {
  AppMenu._();

  static const List<AppMenuItem> items = [
    AppMenuItem(
      key: AppMenuKey.dashboard,
      icon: Icons.dashboard_outlined,
      title: "Tableau de bord",
      route: "/dashboard/admin",
      roles: [
        UserRole.admin,
        UserRole.responsable,
      ],
    ),
    AppMenuItem(
      key: AppMenuKey.clients,
      icon: Icons.people_outline,
      title: "Clients",
      route: "/clients",
      roles: [
        UserRole.admin,
        UserRole.responsable,
        UserRole.agent,
      ],
    ),
    AppMenuItem(
      key: AppMenuKey.bergeries,
      icon: Icons.home_work_outlined,
      title: "Bergeries",
      route: "/bergeries",
      roles: [
        UserRole.admin,
        UserRole.responsable,
        UserRole.agent,
      ],
    ),
    AppMenuItem(
      key: AppMenuKey.interventions,
      icon: Icons.cleaning_services_outlined,
      title: "Interventions",
      route: "/interventions",
      roles: [
        UserRole.admin,
        UserRole.responsable,
        UserRole.agent,
      ],
    ),
    AppMenuItem(
      key: AppMenuKey.abonnements,
      icon: Icons.card_membership_outlined,
      title: "Abonnements",
      route: "/abonnements",
      roles: [
        UserRole.admin,
        UserRole.responsable,
      ],
    ),
    AppMenuItem(
      key: AppMenuKey.rapports,
      icon: Icons.bar_chart_outlined,
      title: "Rapports",
      route: "/rapports",
      roles: [
        UserRole.admin,
        UserRole.responsable,
      ],
    ),
    AppMenuItem(
      key: AppMenuKey.parametres,
      icon: Icons.settings_outlined,
      title: "Paramètres",
      route: "/parametres",
      roles: [
        UserRole.admin,
      ],
    ),
    AppMenuItem(
      key: AppMenuKey.utilisateurs,
      icon: Icons.manage_accounts_outlined,
      title: "Gestion des utilisateurs",
      route: "/utilisateurs",
      roles: [
        UserRole.admin,
      ],
    ),
  ];

  static List<AppMenuItem> forRole(UserRole role) {
    return items.where((item) => item.roles.contains(role)).toList();
  }
}