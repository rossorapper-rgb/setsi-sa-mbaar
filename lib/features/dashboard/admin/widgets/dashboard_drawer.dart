import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/drawer_menu_service.dart';
import '../models/drawer_menu_item.dart';
class DashboardDrawer extends StatelessWidget {
  DashboardDrawer({
    super.key,
    required this.selectedIndex,
  });

  final int selectedIndex;

  final List<DrawerMenuItem> _items =
      DrawerMenuService.instance.menus;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Drawer(
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "SET'SI SA MBAAR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Gestion intelligente d'élevage",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final selected = selectedIndex == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected
                          ? primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: Icon(
                        item.icon,
                        color: selected ? primary : Colors.grey.shade700,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: selected ? primary : null,
                        ),
                      ),
                      selected: selected,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onTap: () => _onItemSelected(context, index),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  "Déconnexion",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onTap: () => context.go('/login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard/admin');
        break;

      case 1:
        context.go('/clients');
        break;

      case 2:
        context.go('/utilisateurs');
        break;

      case 3:
        context.go('/bergeries');
        break;

      case 4:
        context.go('/interventions');
        break;

      case 5:
        context.go('/allo-veto');
        break;

      case 6:
        context.go('/abonnements');
        break;

      case 7:
        context.go('/finances');
        break;

      case 8:
        context.go('/rapports-financiers');
        break;

      case 9:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Ce module sera disponible prochainement.",
            ),
          ),
        );
        break;
    }
  }
}

class _DrawerItem {
  final IconData icon;
  final String title;

  const _DrawerItem({
    required this.icon,
    required this.title,
  });
}