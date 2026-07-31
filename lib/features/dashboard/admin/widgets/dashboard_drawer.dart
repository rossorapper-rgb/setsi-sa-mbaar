import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardDrawer extends StatelessWidget {
  final int selectedIndex;

  const DashboardDrawer({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 42,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: Image.asset(
                  "assets/images/app_icon.png",
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "SET'SI SA MBAAR",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B6E4F),
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Administration",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    title: "Tableau de bord",
                    index: 0,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.people_alt_rounded,
                    title: "Clients",
                    index: 1,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.home_rounded,
                    title: "Bergeries",
                    index: 2,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.pets,
                    title: "Moutons",
                    index: 3,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.favorite_rounded,
                    title: "Gestations",
                    index: 4,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.build_circle_rounded,
                    title: "Interventions",
                    index: 5,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.card_membership_rounded,
                    title: "Abonnements",
                    index: 6,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.payments_rounded,
                    title: "Paiements",
                    index: 7,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.bar_chart_rounded,
                    title: "Rapports",
                    index: 8,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.settings_rounded,
                    title: "Paramètres",
                    index: 9,
                  ),
                ],
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                "Déconnexion",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => context.go('/login'),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required int index,
      }) {
    final bool selected = selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: selected ? const Color(0xFF0B6E4F) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? const Color(0xFF0B6E4F) : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: const Color(0xFFE8F5F0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () {
        switch (index) {
          case 0:
            context.go('/dashboard/admin');
            break;

          case 1:
            context.go('/clients');
            break;

          case 2:
            context.go('/bergeries');
            break;

          case 3:
            context.go('/moutons');
            break;

          case 4:
            context.go('/gestations');
            break;

          case 5:
            context.go('/interventions');
            break;

          case 6:
            context.go('/abonnements');
            break;

          case 7:
            context.go('/paiements');
            break;

          case 8:
            context.go('/rapports');
            break;

          case 9:
            context.go('/parametres');
            break;

          default:
            break;
        }
      },
    );
  }
}