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

            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFF0B6E4F),
              child: Icon(
                Icons.pets,
                size: 38,
                color: Colors.white,
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
              style: TextStyle(
                color: Colors.grey,
              ),
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
                    icon: Icons.home_work_rounded,
                    title: "Troupeaux",
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
                    icon: Icons.build_circle_rounded,
                    title: "Interventions",
                    index: 4,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.card_membership_rounded,
                    title: "Abonnements",
                    index: 5,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.payments_rounded,
                    title: "Paiements",
                    index: 6,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.bar_chart_rounded,
                    title: "Rapports",
                    index: 7,
                  ),
                  _buildItem(
                    context,
                    icon: Icons.settings_rounded,
                    title: "Paramètres",
                    index: 8,
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
              onTap: () {
                context.go('/login');
              },
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
        Navigator.pop(context);

        switch (index) {
          case 0:
            context.go('/dashboard/admin');
            break;

          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$title : module en cours de développement"),
              ),
            );
        }
      },
    );
  }
}