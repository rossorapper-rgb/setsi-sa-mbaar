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

    final stats = [
      StatCard(
        title: "Clients",
        value: dashboard.clients.toString(),
        subtitle: "Clients enregistrés",
        evolution: "+12%",
        icon: Icons.people_alt_rounded,
        color: AppColors.info,
      ),
      StatCard(
        title: "Moutons",
        value: dashboard.moutons.toString(),
        subtitle: "Dans le système",
        evolution: "+8%",
        icon: Icons.pets_rounded,
        color: AppColors.success,
      ),
      StatCard(
        title: "Interventions",
        value: dashboard.interventions.toString(),
        subtitle: "Ce mois",
        evolution: "+5%",
        icon: Icons.home_repair_service_rounded,
        color: AppColors.warning,
      ),
      StatCard(
        title: "Revenus",
        value: dashboard.revenusFormat,
        subtitle: "Ce mois",
        evolution: "+18%",
        icon: Icons.payments_rounded,
        color: AppColors.danger,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: width < 700 ? 2.6 : 1.45,
      ),
      itemBuilder: (_, index) => stats[index],
    );
  }
}