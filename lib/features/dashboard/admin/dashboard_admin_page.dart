import 'package:flutter/material.dart';

import '../../../../core/session/current_user_service.dart';
import '../../utilisateurs/models/user_role.dart';
import 'widgets/dashboard_drawer.dart';
import 'widgets/dashboard_admin_body.dart';

class DashboardAdminPage extends StatelessWidget {
  const DashboardAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        MediaQuery.of(context).size.width >= 900;

    final currentUser =
        CurrentUserService.instance.currentUser;

    final String nomComplet =
    currentUser?.nomComplet.isNotEmpty == true
        ? currentUser!.nomComplet
        : "Utilisateur";

    final String role = _getRoleLabel(
      CurrentUserService.instance.role,
    );

    final String initiale =
    nomComplet.trim().isNotEmpty
        ? nomComplet.trim().substring(0, 1).toUpperCase()
        : "U";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: isDesktop
          ? null
          : AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "SET'SI SA MBAAR",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      drawer: isDesktop
          ? null
          : DashboardDrawer(
        selectedIndex: 0,
      ),

      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              SizedBox(
                width: 260,
                child: DashboardDrawer(
                  selectedIndex: 0,
                ),
              ),

            Expanded(
              child: Column(
                children: [
                  if (isDesktop)
                    Container(
                      height: 75,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Rechercher...",
                                prefixIcon: Icon(
                                  Icons.search,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_none,
                            ),
                          ),

                          const SizedBox(width: 10),

                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                            const Color(0xFF0B6E4F),
                            child: Text(
                              initiale,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                nomComplet,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                role,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: const DashboardAdminBody(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleLabel(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return "Administrateur";

      case UserRole.responsable:
        return "Responsable";

      case UserRole.technicien:
        return "Technicien";

      case UserRole.client:
        return "Client";

      case null:
        return "Utilisateur";
    }
  }
}