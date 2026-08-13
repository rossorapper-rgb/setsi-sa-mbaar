import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/session/current_user_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../utilisateurs/models/user_role.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.of(context).size.width < 900;

    final currentUser = CurrentUserService.instance.currentUser;

    final String nomComplet =
    currentUser?.nomComplet.isNotEmpty == true
        ? currentUser!.nomComplet
        : "Utilisateur";

    final UserRole? userRole =
        CurrentUserService.instance.role;

    final String role = _getRoleLabel(userRole);

    final String date =
    DateFormat(
      "EEEE dd MMMM yyyy",
      "fr_FR",
    ).format(DateTime.now());

    final String initiale =
    nomComplet.trim().isNotEmpty
        ? nomComplet.trim().substring(0, 1).toUpperCase()
        : "U";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //---------------------------------------------------------
          // Ligne supérieure
          //---------------------------------------------------------

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              SizedBox(
                width: mobile ? 320 : 450,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bonjour, $nomComplet 👋",
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 28,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Bienvenue sur votre espace de gestion SET'SI SA MBAAR.",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.subtitle,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      date,
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xffF6F7FB),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                        ),
                      ),

                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 20),

                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      initiale,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomComplet,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 2),

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
            ],
          ),

          const SizedBox(height: 28),

          //---------------------------------------------------------
          // Barre de recherche
          //---------------------------------------------------------

          SizedBox(
            height: 52,
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xffF7F8FC),
                hintText:
                "Rechercher un client, un mouton, une intervention...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
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