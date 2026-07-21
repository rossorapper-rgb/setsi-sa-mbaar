import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:setsi_sa_mbaar/core/theme/app_colors.dart';
import 'package:setsi_sa_mbaar/core/widgets/stat_card.dart';
import 'package:setsi_sa_mbaar/providers/dashboard_provider.dart';

class DashboardStats extends ConsumerWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    final width = MediaQuery.of(context).size.width;

    int crossAxisCount;

    if (width >= 1400) {
      crossAxisCount = 4;
    } else if (width >= 900) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: width < 700 ? 1.75 : 1.25,
      ),
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return StatCard(
              title: "Clients",
              value: dashboard.clients.toString(),
              subtitle: "Clients enregistrés",
              evolution: "+12%",
              icon: Icons.people_alt_rounded,
              color: AppColors.info,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Module Clients (bientôt disponible)"),
                  ),
                );
              },
            );

          case 1:
            return StatCard(
              title: "Moutons",
              value: dashboard.moutons.toString(),
              subtitle: "Dans le système",
              evolution: "+8%",
              icon: Icons.pets_rounded,
              color: AppColors.success,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Module Moutons (bientôt disponible)"),
                  ),
                );
              },
            );

          case 2:
            return StatCard(
              title: "Interventions",
              value: dashboard.interventions.toString(),
              subtitle: "Ce mois",
              evolution: "+5%",
              icon: Icons.home_repair_service_rounded,
              color: AppColors.warning,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Module Interventions (bientôt disponible)"),
                  ),
                );
              },
            );

          default:
            return StatCard(
              title: "Revenus",
              value: dashboard.revenusFormat,
              subtitle: "Ce mois",
              evolution: "+18%",
              icon: Icons.payments_rounded,
              color: AppColors.danger,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Module Revenus (bientôt disponible)"),
                  ),
                );
              },
            );
        }
      },
    );
  }
}