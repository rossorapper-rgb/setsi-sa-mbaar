import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final int crossAxisCount;

    if (width >= 1200) {
      crossAxisCount = 4;
    } else if (width >= 700) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    final actions = [
      _QuickAction(
        title: "Nouveau client",
        subtitle: "Créer un client",
        icon: Icons.person_add_alt_1_rounded,
        color: Colors.blue,
        onTap: () => context.go('/clients/add'),
      ),
      _QuickAction(
        title: "Nouveau mouton",
        subtitle: "Ajouter un mouton",
        icon: Icons.pets_rounded,
        color: Colors.green,
        onTap: () => context.go('/bergeries'),
      ),
      _QuickAction(
        title: "Nouvelle gestation",
        subtitle: "Enregistrer une saillie",
        icon: Icons.favorite_rounded,
        color: Colors.pink,
        onTap: () => context.go('/bergeries'),
      ),
      _QuickAction(
        title: "Intervention",
        subtitle: "Créer une intervention",
        icon: Icons.medical_services_rounded,
        color: Colors.orange,
        onTap: () => context.go('/interventions'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 2.3,
          ),
          itemBuilder: (_, index) {
            final action = actions[index];

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: action.onTap,
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: action.color.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            action.icon,
                            color: action.color,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                action.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                action.subtitle,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
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