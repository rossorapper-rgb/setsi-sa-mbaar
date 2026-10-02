import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:setsi_sa_mbaar/core/theme/app_colors.dart';
import 'package:setsi_sa_mbaar/core/widgets/stat_card.dart';
import 'package:setsi_sa_mbaar/providers/dashboard_provider.dart';

class DashboardStats extends ConsumerWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(dashboardProvider).when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(child: Text("Impossible de charger les statistiques.\nErreur : $error")),
              IconButton(onPressed: () => ref.invalidate(dashboardProvider), icon: const Icon(Icons.refresh)),
            ],
          ),
        ),
      ),
      data: (dashboard) {
        final cards = [
          _Stat("Clients", dashboard.clients, "Clients enregistrés", Icons.people_alt_rounded, AppColors.info, "/clients"),
          _Stat("Clients actifs", dashboard.clientsActifs, "Clients actifs", Icons.person_rounded, AppColors.success, "/clients"),
          _Stat("Bergeries", dashboard.bergeries, "Bergeries enregistrées", Icons.home_work_rounded, AppColors.primary, "/bergeries"),
          _Stat("Bergeries actives", dashboard.bergeriesActives, "Bergeries actives", Icons.home_work_rounded, AppColors.warning, "/bergeries"),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1250 ? 4 : constraints.maxWidth >= 780 ? 3 : constraints.maxWidth >= 520 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: constraints.maxWidth < 520 ? 92 : 112,
              ),
              itemBuilder: (context, index) {
                final card = cards[index];
                return StatCard(
                  title: card.title,
                  value: card.value.toString(),
                  subtitle: card.subtitle,
                  evolution: "",
                  icon: card.icon,
                  color: card.color,
                  onTap: () => context.go(card.route),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _Stat {
  final String title;
  final int value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _Stat(this.title, this.value, this.subtitle, this.icon, this.color, this.route);
}
