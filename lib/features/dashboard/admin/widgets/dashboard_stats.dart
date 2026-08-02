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

    final int crossAxisCount;

    if (width >= 1600) {
      crossAxisCount = 4;
    } else if (width >= 1200) {
      crossAxisCount = 3;
    } else if (width >= 700) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    final cards = <_DashboardStatData>[
      _DashboardStatData(
        title: "Clients",
        value: dashboard.clients.toString(),
        subtitle: "Clients enregistrés",
        evolution: "+12%",
        icon: Icons.people_alt_rounded,
        color: AppColors.info,
      ),
      _DashboardStatData(
        title: "Moutons",
        value: dashboard.moutons.toString(),
        subtitle: "Dans le système",
        evolution: "+8%",
        icon: Icons.pets_rounded,
        color: AppColors.success,
      ),
      _DashboardStatData(
        title: "Bergeries",
        value: dashboard.bergeries.toString(),
        subtitle: "Bergeries enregistrées",
        evolution: "+6%",
        icon: Icons.home_rounded,
        color: Colors.brown,
      ),
      _DashboardStatData(
        title: "Gestations",
        value: dashboard.gestations.toString(),
        subtitle: "En cours",
        evolution: "+4%",
        icon: Icons.favorite_rounded,
        color: Colors.pink,
      ),
      _DashboardStatData(
        title: "Interventions",
        value: dashboard.interventions.toString(),
        subtitle: "Ce mois",
        evolution: "+5%",
        icon: Icons.home_repair_service_rounded,
        color: AppColors.warning,
      ),
      _DashboardStatData(
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
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: width < 700 ? 1.75 : 1.25,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];

        return StatCard(
          title: card.title,
          value: card.value,
          subtitle: card.subtitle,
          evolution: card.evolution,
          icon: card.icon,
          color: card.color,
          onTap: () {
            switch (card.title) {
              case "Clients":
              // TODO: Navigation vers Clients
                break;

              case "Bergeries":
              // TODO: Navigation vers Bergeries
                break;

              case "Moutons":
              // TODO: Navigation vers Moutons
                break;

              case "Gestations":
              // TODO: Navigation vers Gestations
                break;

              case "Interventions":
              // TODO: Navigation vers Interventions
                break;

              case "Revenus":
              // TODO: Navigation vers Finances
                break;
            }
          },
        );
      },
    );
  }
}

class _DashboardStatData {
  final String title;
  final String value;
  final String subtitle;
  final String evolution;
  final IconData icon;
  final Color color;

  const _DashboardStatData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.evolution,
    required this.icon,
    required this.color,
  });
}