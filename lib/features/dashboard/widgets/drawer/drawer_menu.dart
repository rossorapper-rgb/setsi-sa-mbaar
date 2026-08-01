import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_menu.dart';
import '../../../../core/navigation/app_menu_key.dart';
import '../../../../core/session/current_user.dart';
import 'drawer_menu_item.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    super.key,
    required this.currentMenu,
  });

  final AppMenuKey currentMenu;

  @override
  Widget build(BuildContext context) {
    final menus = AppMenu.forRole(CurrentUser.role);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];

        return DrawerMenuItem(
          icon: menu.icon,
          title: menu.title,
          selected: menu.key == currentMenu,
          onTap: () {
            context.go(menu.route);
          },
        );
      },
    );
  }
}