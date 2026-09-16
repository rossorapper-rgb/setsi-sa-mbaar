import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/session/current_user_service.dart';
import '../../../utilisateurs/models/user_role.dart';
import '../../../gestation/pages/add_gestation_page.dart';
import '../../../bergeries/models/bergerie_model.dart';
import '../../../bergeries/repository/firebase_bergerie_repository.dart';
import '../../../moutons/pages/add_mouton_page.dart';
import '../../../moutons/providers/mouton_provider.dart';
import '../../../../providers/dashboard_provider.dart';

class DashboardQuickActions extends ConsumerWidget {
  const DashboardQuickActions({super.key});

  Future<void> _ajouterMouton(BuildContext context, WidgetRef ref) async {
    final utilisateur = CurrentUserService.instance.currentUser;
    if (utilisateur == null) return;

    try {
      final bergeries = await FirebaseBergerieRepository()
          .getBergeriesByClient(utilisateur.id);

      if (!context.mounted) return;

      BergerieModel? bergerie;
      if (bergeries.length == 1) {
        bergerie = bergeries.first;
      } else if (bergeries.length > 1) {
        bergerie = await showDialog<BergerieModel>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text("Choisir la bergerie"),
            content: SizedBox(
              width: 420,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: bergeries.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final item = bergeries[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.home_work),
                    ),
                    title: Text(item.nom),
                    subtitle: Text(
                      item.adresse.isEmpty ? "Bergerie" : item.adresse,
                    ),
                    onTap: () => Navigator.pop(dialogContext, item),
                  );
                },
              ),
            ),
          ),
        );
      }

      final resultat = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AddMoutonPage(bergerie: bergerie),
        ),
      );

      if (resultat == true && context.mounted) {
        ref.invalidate(dashboardProvider);
        ref.invalidate(moutonsProvider);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'ouvrir l'ajout : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = CurrentUserService.instance.role;
    final isClient = role == UserRole.client;

    final actions = <_QuickAction>[
      _QuickAction(
        title: isClient ? "Ajouter un mouton" : "Nouveau mouton",
        icon: Icons.pets_rounded,
        color: Colors.blue,
        onTap: () {
          if (isClient) {
            _ajouterMouton(context, ref);
          } else {
            context.go('/bergeries');
          }
        },
      ),
      _QuickAction(
        title: "Nouvelle gestation",
        icon: Icons.favorite_rounded,
        color: Colors.orange,
        onTap: () => context.go('/gestations'),
      ),
      _QuickAction(
        title: isClient ? "Enregistrer un soin" : "Intervention",
        icon: Icons.medical_services_rounded,
        color: Colors.blue,
        onTap: () => context.go('/interventions'),
      ),
      _QuickAction(
        title: "Ajouter une alimentation",
        icon: Icons.grass_rounded,
        color: Colors.orange,
        onTap: () => context.go('/interventions'),
      ),
      _QuickAction(
        title: "Enregistrer une activité",
        icon: Icons.assignment_rounded,
        color: Colors.blue,
        onTap: () => context.go('/interventions'),
      ),
      _QuickAction(
        title: "Voir mes rapports",
        icon: Icons.bar_chart_rounded,
        color: Colors.orange,
        onTap: () => context.go('/rapports-financiers'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Actions rapides",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1050 ? 3 : width >= 520 ? 2 : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: columns == 1 ? 4.2 : 2.55,
              ),
              itemBuilder: (_, index) {
                final action = actions[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: action.onTap,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: action.color.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              action.icon,
                              color: action.color,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              action.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}