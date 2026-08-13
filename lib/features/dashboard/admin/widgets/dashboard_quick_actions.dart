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
    final session = CurrentUserService.instance;
    final utilisateur = session.currentUser;

    if (utilisateur == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Utilisateur non connecté."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final bergerieRepository = FirebaseBergerieRepository();

      final bergeries = await bergerieRepository.getBergeriesByClient(
        utilisateur.id,
      );

      if (!context.mounted) return;

      if (bergeries.isEmpty) {
        final resultat = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => const AddMoutonPage(),
          ),
        );

        if (resultat == true && context.mounted) {
          ref.invalidate(dashboardProvider);
          ref.invalidate(moutonsProvider);
        }

        return;
      }

      if (bergeries.length == 1) {
        final resultat = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => AddMoutonPage(
              bergerie: bergeries.first,
            ),
          ),
        );

        if (resultat == true && context.mounted) {
          ref.invalidate(dashboardProvider);
          ref.invalidate(moutonsProvider);
        }
        return;
      }

      final bergerie = await showDialog<BergerieModel>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
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
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.pop(dialogContext, item);
                    },
                  );
                },
              ),
            ),
          );
        },
      );

      if (bergerie == null) return;
      if (!context.mounted) return;

      final resultat = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AddMoutonPage(
            bergerie: bergerie,
          ),
        ),
      );

      if (resultat == true && context.mounted) {
        ref.invalidate(dashboardProvider);
          ref.invalidate(moutonsProvider);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible d'ouvrir l'ajout du mouton : $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width =
        MediaQuery.of(context).size.width;

    final int crossAxisCount;

    if (width >= 1200) {
      crossAxisCount = 4;
    } else if (width >= 700) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    final role =
        CurrentUserService.instance.role;

    final List<_QuickAction> actions;

    // ==========================================================
    // ESPACE CLIENT
    // ==========================================================

    if (role == UserRole.client) {
      actions = [
        // --------------------------------------------------------
        // AJOUTER UN MOUTON
        // --------------------------------------------------------

        _QuickAction(
          title: "Ajouter un mouton",
          subtitle:
          "Enregistrer un nouveau mouton",
          icon: Icons.pets_rounded,
          color: Colors.green,
          onTap: () {
            _ajouterMouton(context, ref);
          },
        ),

        // --------------------------------------------------------
        // NOUVELLE GESTATION
        // --------------------------------------------------------

        _QuickAction(
          title: "Nouvelle gestation",
          subtitle:
          "Enregistrer une gestation",
          icon: Icons.favorite_rounded,
          color: Colors.pink,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const AddGestationPage(),
              ),
            );
          },
        ),

        // --------------------------------------------------------
        // MES INTERVENTIONS
        // --------------------------------------------------------

        _QuickAction(
          title: "Mes interventions",
          subtitle:
          "Consulter mes interventions",
          icon:
          Icons.medical_services_rounded,
          color: Colors.orange,
          onTap: () {
            context.go('/interventions');
          },
        ),
      ];
    }

    // ==========================================================
    // ESPACE ADMIN / RESPONSABLE / TECHNICIEN
    // ==========================================================

    else {
      actions = [
        _QuickAction(
          title: "Nouveau client",
          subtitle: "Créer un client",
          icon:
          Icons.person_add_alt_1_rounded,
          color: Colors.blue,
          onTap: () {
            context.go('/clients/add');
          },
        ),

        _QuickAction(
          title: "Nouveau mouton",
          subtitle: "Ajouter un mouton",
          icon: Icons.pets_rounded,
          color: Colors.green,
          onTap: () {
            context.go('/bergeries');
          },
        ),

        _QuickAction(
          title: "Nouvelle gestation",
          subtitle:
          "Enregistrer une saillie",
          icon: Icons.favorite_rounded,
          color: Colors.pink,
          onTap: () {
            context.go('/gestations');
          },
        ),

        _QuickAction(
          title: "Intervention",
          subtitle:
          "Créer une intervention",
          icon:
          Icons.medical_services_rounded,
          color: Colors.orange,
          onTap: () {
            context.go('/interventions');
          },
        ),
      ];
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          "Actions rapides",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
            crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 2.3,
          ),
          itemBuilder: (_, index) {
            final action = actions[index];

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius:
                BorderRadius.circular(18),
                onTap: action.onTap,
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: .05),
                        blurRadius: 15,
                        offset:
                        const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:
                    const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration:
                          BoxDecoration(
                            color: action.color
                                .withValues(
                              alpha: .12,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(16),
                          ),
                          child: Icon(
                            action.icon,
                            color: action.color,
                            size: 30,
                          ),
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                action.title,
                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                action.subtitle,
                                style: TextStyle(
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Icon(
                          Icons
                              .arrow_forward_ios_rounded,
                          color: action.color,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}