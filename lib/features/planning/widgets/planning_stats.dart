import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../interventions/providers/intervention_provider.dart';

class PlanningStats extends ConsumerWidget {
  const PlanningStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interventions = ref.watch(interventionProvider);

    final total = interventions.length;

    final planifiees =
        interventions.where((i) => i.statut == "Planifiée").length;

    final enCours =
        interventions.where((i) => i.statut == "En cours").length;

    final terminees =
        interventions.where((i) => i.statut == "Terminée").length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            titre: "Total",
            valeur: total.toString(),
            couleur: Colors.indigo,
            icone: Icons.assignment,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            titre: "Planifiées",
            valeur: planifiees.toString(),
            couleur: Colors.orange,
            icone: Icons.schedule,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            titre: "En cours",
            valeur: enCours.toString(),
            couleur: Colors.blue,
            icone: Icons.play_circle_fill,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            titre: "Terminées",
            valeur: terminees.toString(),
            couleur: Colors.green,
            icone: Icons.check_circle,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String titre;
  final String valeur;
  final Color couleur;
  final IconData icone;

  const _StatCard({
    required this.titre,
    required this.valeur,
    required this.couleur,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: couleur.withOpacity(0.15),
              child: Icon(
                icone,
                color: couleur,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valeur,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(titre),
              ],
            ),
          ],
        ),
      ),
    );
  }
}