import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction("Nouveau client", Icons.person_add_alt_1_rounded, () => context.go('/clients/add')),
      _QuickAction("Nouvelle bergerie", Icons.add_business_rounded, () => context.go('/bergeries')),
      _QuickAction("Voir les clients", Icons.people_alt_rounded, () => context.go('/clients')),
      _QuickAction("Voir les bergeries", Icons.home_work_rounded, () => context.go('/bergeries')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Actions rapides", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1050 ? 4 : constraints.maxWidth >= 520 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 72,
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
                          BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Icon(action.icon, color: Theme.of(context).colorScheme.primary, size: 24),
                          const SizedBox(width: 12),
                          Expanded(child: Text(action.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
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
  final VoidCallback onTap;

  const _QuickAction(this.title, this.icon, this.onTap);
}
