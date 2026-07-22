import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardDrawer extends StatelessWidget {
  final int selectedIndex;

  const DashboardDrawer({
    super.key,
    required this.selectedIndex,
  });

  static const Color primaryColor = Color(0xFF0B6E4F);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 25),

            const CircleAvatar(
              radius: 38,
              backgroundColor: primaryColor,
              child: Icon(
                Icons.pets,
                color: Colors.white,
                size: 40,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "SET'SI SA MBAAR",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: primaryColor,
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
                  _menuItem(
                    context,
                    index: 0,
                    icon: Icons.dashboard_rounded,
                    title: "Tableau de bord",
                    route: "/dashboard/admin",
                  ),

                  _menuItem(
                    context,
                    index: 1,
                    icon: Icons.calendar_month_rounded,
                    title: "Planning",
                    route: "/planning",
                  ),

                  _menuItem(
                    context,
                    index: 2,
                    icon: Icons.people_alt_rounded,
                    title: "Clients",
                    route: "/clients",
                  ),

                  _menuItem(
                    context,
                    index: 3,
                    icon: Icons.home_work_rounded,
                    title: "Troupeaux",
                  ),

                  _menuItem(
                    context,
                    index: 4,
                    icon: Icons.pets,
                    title: "Moutons",
                  ),

                  _menuItem(
                    context,
                    index: 5,
                    icon: Icons.build_circle_rounded,
                    title: "Interventions",
                    route: "/interventions",
                  ),

                  _menuItem(
                    context,
                    index: 6,
                    icon: Icons.card_membership_rounded,
                    title: "Abonnements",
                  ),

                  _menuItem(
                    context,
                    index: 7,
                    icon: Icons.payments_rounded,
                    title: "Paiements",
                  ),

                  _menuItem(
                    context,
                    index: 8,
                    icon: Icons.bar_chart_rounded,
                    title: "Rapports",
                  ),

                  _menuItem(
                    context,
                    index: 9,
                    icon: Icons.settings_rounded,
                    title: "Paramètres",
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
              onTap: () => context.go("/login"),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
      BuildContext context, {
        required int index,
        required IconData icon,
        required String title,
        String? route,
      }) {
    final bool selected = selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: selected ? primaryColor : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? primaryColor : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: const Color(0xFFE8F5F0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () {
        if (route != null) {
          context.go(route);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "$title : module en cours de développement",
              ),
            ),
          );
        }
      },
    );
  }
}