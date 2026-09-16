import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:setsi_sa_mbaar/core/session/current_user_service.dart';
import 'package:setsi_sa_mbaar/core/theme/app_colors.dart';
import 'package:setsi_sa_mbaar/core/widgets/stat_card.dart';
import 'package:setsi_sa_mbaar/features/utilisateurs/models/user_role.dart';
import 'package:setsi_sa_mbaar/providers/dashboard_provider.dart';

class DashboardStats extends ConsumerWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Impossible de charger les statistiques.\nErreur : $error",
                ),
              ),
              IconButton(
                onPressed: () => ref.invalidate(dashboardProvider),
                icon: const Icon(Icons.refresh),
                tooltip: "Réessayer",
              ),
            ],
          ),
        ),
      ),
      data: (dashboard) {
        final role = CurrentUserService.instance.role;
        final List<_DashboardStatData> cards;

        if (role == UserRole.client) {
          cards = [
            _DashboardStatData(
              title: "Mes moutons",
              value: dashboard.moutons.toString(),
              subtitle: "Moutons enregistrés",
              icon: Icons.pets_rounded,
              color: AppColors.info,
              route: "/moutons",
            ),
            _DashboardStatData(
              title: "Mes gestations",
              value: dashboard.gestations.toString(),
              subtitle: "Gestations en cours",
              icon: Icons.favorite_rounded,
              color: Colors.orange,
              route: "/gestations",
            ),
            _DashboardStatData(
              title: "Mes interventions",
              value: dashboard.interventions.toString(),
              subtitle: "Interventions",
              icon: Icons.medical_services_rounded,
              color: AppColors.warning,
              route: "/interventions",
            ),
            _DashboardStatData(
              title: "Mes paiements",
              value: dashboard.revenusFormat,
              subtitle: "Paiements enregistrés",
              icon: Icons.payments_rounded,
              color: AppColors.success,
              route: "/paiements",
            ),
          ];
        } else {
          cards = [
            _DashboardStatData(
              title: "Moutons",
              value: dashboard.moutons.toString(),
              subtitle: "Dans l'élevage",
              icon: Icons.pets_rounded,
              color: AppColors.info,
              route: "/bergeries",
            ),
            _DashboardStatData(
              title: "Gestations",
              value: dashboard.gestations.toString(),
              subtitle: "En cours",
              icon: Icons.favorite_rounded,
              color: Colors.orange,
              route: "/gestations",
            ),
            _DashboardStatData(
              title: "À surveiller",
              value: "0",
              subtitle: "Animaux à vérifier",
              icon: Icons.medical_services_rounded,
              color: AppColors.warning,
              route: "/interventions",
            ),
            _DashboardStatData(
              title: "Alimentation",
              value: "Normale",
              subtitle: "Stocks suffisants",
              icon: Icons.grass_rounded,
              color: AppColors.success,
              route: "/interventions",
            ),
          ];
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final int crossAxisCount;

            if (width >= 1100) {
              crossAxisCount = 4;
            } else if (width >= 650) {
              crossAxisCount = 2;
            } else {
              crossAxisCount = 1;
            }

            final aspectRatio = crossAxisCount == 1
                ? 2.4
                : crossAxisCount == 2
                    ? 2.0
                    : 1.55;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                final card = cards[index];
                return StatCard(
                  title: card.title,
                  value: card.value,
                  subtitle: card.subtitle,
                  evolution: "",
                  icon: card.icon,
                  color: card.color,
                  onTap: card.route == null
                      ? null
                      : () => context.go(card.route!),
                );
              },
            );
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
  final IconData icon;
  final Color color;
  final String? route;

  const _DashboardStatData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.route,
  });
}