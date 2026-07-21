import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/intervention_provider.dart';
import 'intervention_details_page.dart';
import '../widgets/intervention_actions_bar.dart';
import 'add_intervention_page.dart';

class InterventionsPage extends ConsumerWidget {
  const InterventionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interventions = ref.watch(interventionProvider);

    final planifiees =
        interventions.where((i) => i.statut == 'Planifiée').length;

    final enCours =
        interventions.where((i) => i.statut == 'En cours').length;

    final terminees =
        interventions.where((i) => i.statut == 'Terminée').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 34,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Gestion des interventions",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              InterventionActionsBar(
                totalInterventions: interventions.length,
                onAdd: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddInterventionPage(),
                    ),
                  );
                },
                onRefresh: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Actualisation effectuée"),
                    ),
                  );
                },
                onExportPdf: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Export PDF (à venir)"),
                    ),
                  );
                },
                onExportExcel: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Export Excel (à venir)"),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              Row(
                children: [
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
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: interventions.length,
                  itemBuilder: (context, index) {
                    final intervention = interventions[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InterventionDetailsPage(
                                intervention: intervention,
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              intervention.numero.substring(
                                intervention.numero.length - 2,
                              ),
                            ),
                          ),
                          title: Text(intervention.clientNom),
                          subtitle: Text(
                            "${intervention.numero}\n"
                                "${intervention.agent} • ${intervention.heureDebut}",
                          ),
                          isThreeLine: true,
                          trailing: Chip(
                            label: Text(intervention.statut),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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