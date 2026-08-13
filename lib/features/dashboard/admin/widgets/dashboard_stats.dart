import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Impossible de charger les statistiques.",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      "Erreur : ${error.toString()}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.invalidate(dashboardProvider);
                },
                icon: const Icon(Icons.refresh),
                tooltip: "Réessayer",
              ),
            ],
          ),
        ),
      ),
      data: (dashboard) {
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

        final role = CurrentUserService.instance.role;

        // ======================================================
        // DASHBOARD CLIENT
        // ======================================================

        final List<_DashboardStatData> cards;

        if (role == UserRole.client) {
          cards = [
            _DashboardStatData(
              title: "Mes moutons",
              value: dashboard.moutons.toString(),
              subtitle: "Mes moutons enregistrés",
              evolution: "",
              icon: Icons.pets_rounded,
              color: AppColors.success,
              route: "/bergeries",
            ),
            _DashboardStatData(
              title: "Mes gestations",
              value: dashboard.gestations.toString(),
              subtitle: "Gestations en cours",
              evolution: "",
              icon: Icons.favorite_rounded,
              color: Colors.pink,
              route: "/gestations",
            ),
            _DashboardStatData(
              title: "Mes interventions",
              value: dashboard.interventions.toString(),
              subtitle: "Mes interventions",
              evolution: "",
              icon: Icons.home_repair_service_rounded,
              color: AppColors.warning,
              route: "/interventions",
            ),
            _DashboardStatData(
              title: "Mes paiements",
              value: dashboard.revenusFormat,
              subtitle: "Paiements enregistrés",
              evolution: "",
              icon: Icons.payments_rounded,
              color: AppColors.danger,
              route: "/paiements",
            ),
          ];
        }

        // ======================================================
        // DASHBOARD ADMIN / RESPONSABLE / TECHNICIEN
        // ======================================================

        else {
          cards = [
            _DashboardStatData(
              title: "Clients",
              value: dashboard.clients.toString(),
              subtitle: "Clients enregistrés",
              evolution: "",
              icon: Icons.people_alt_rounded,
              color: AppColors.info,
              route: "/clients",
            ),
            _DashboardStatData(
              title: "Moutons",
              value: dashboard.moutons.toString(),
              subtitle: "Dans le système",
              evolution: "",
              icon: Icons.pets_rounded,
              color: AppColors.success,
              route: "/bergeries",
            ),
            _DashboardStatData(
              title: "Bergeries",
              value: dashboard.bergeries.toString(),
              subtitle: "Bergeries enregistrées",
              evolution: "",
              icon: Icons.home_rounded,
              color: Colors.brown,
              route: "/bergeries",
            ),
            _DashboardStatData(
              title: "Gestations",
              value: dashboard.gestations.toString(),
              subtitle: "En cours",
              evolution: "",
              icon: Icons.favorite_rounded,
              color: Colors.pink,
              route: "/gestations",
            ),
            _DashboardStatData(
              title: "Interventions",
              value: dashboard.interventions.toString(),
              subtitle: "Interventions",
              evolution: "",
              icon: Icons.home_repair_service_rounded,
              color: AppColors.warning,
              route: "/interventions",
            ),
            _DashboardStatData(
              title: "Revenus",
              value: dashboard.revenusFormat,
              subtitle: "Paiements encaissés",
              evolution: "",
              icon: Icons.payments_rounded,
              color: AppColors.danger,
              route: "/finances",
            ),
          ];
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio:
            width < 700 ? 1.75 : 1.25,
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
                if (card.route == null) return;

                context.go(card.route!);
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
  final String evolution;
  final IconData icon;
  final Color color;
  final String? route;

  const _DashboardStatData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.evolution,
    required this.icon,
    required this.color,
    this.route,
  });
}