import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/intervention_model.dart';
import '../providers/intervention_provider.dart';
import '../widgets/intervention_actions_bar.dart';
import 'add_intervention_page.dart';
import 'intervention_details_page.dart';
import 'package:go_router/go_router.dart';

class InterventionsPage extends ConsumerWidget {
const InterventionsPage({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
final interventionsAsync =
ref.watch(interventionProvider);

return interventionsAsync.when(
loading: () => const Scaffold(
body: Center(
child: CircularProgressIndicator(),
),
),

error: (error, stackTrace) => Scaffold(
  appBar: AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        context.go('/dashboard/admin');
      },
    ),
    title: const Text(
      "Gestion des interventions",
    ),
  ),
body: Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
const Icon(
Icons.error_outline,
color: Colors.red,
size: 70,
),
const SizedBox(height: 16),
Text(
error.toString(),
textAlign: TextAlign.center,
),
const SizedBox(height: 20),
ElevatedButton.icon(
onPressed: () {
ref
.read(
interventionProvider.notifier,
)
.rafraichir();
},
icon: const Icon(Icons.refresh),
label: const Text(
"Réessayer",
),
),
],
),
),
),
),

data: (List<InterventionModel> interventions) {

final planifiees = interventions
.where(
(i) => i.statut == "Planifiée",
)
.length;

final enCours = interventions
.where(
(i) => i.statut == "En cours",
)
.length;

final terminees = interventions
.where(
(i) => i.statut == "Terminée",
)
.length;

return Scaffold(
  backgroundColor:
  const Color(0xFFF5F7FA),

  appBar: AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        context.go('/dashboard/admin');
      },
    ),
    title: const Text(
      "Gestion des interventions",
    ),
  ),

  body: SafeArea(
child: RefreshIndicator(
onRefresh: () async {
await ref
.read(
interventionProvider
.notifier,
)
.rafraichir();
},

child: Padding(
padding:
const EdgeInsets.all(24),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

InterventionActionsBar(
totalInterventions:
interventions.length,
  onAdd: () async {
    final resultat =
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const AddInterventionPage(),
      ),
    );

    if (resultat == true && context.mounted) {
      ref
          .read(
        interventionProvider.notifier,
      )
          .rafraichir();
    }
  },

  onRefresh: () {
    ref
        .read(
      interventionProvider.notifier,
    )
        .rafraichir();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Actualisation effectuée",
        ),
      ),
    );
  },

  onExportPdf: () {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Export PDF (à venir)",
        ),
      ),
    );
  },

  onExportExcel: () {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Export Excel (à venir)",
        ),
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
          valeur:
          planifiees.toString(),
          couleur: Colors.orange,
          icone: Icons.schedule,
        ),
      ),

      const SizedBox(width: 16),

      Expanded(
        child: _StatCard(
          titre: "En cours",
          valeur:
          enCours.toString(),
          couleur: Colors.blue,
          icone:
          Icons.play_circle_fill,
        ),
      ),

      const SizedBox(width: 16),

      Expanded(
        child: _StatCard(
          titre: "Terminées",
          valeur:
          terminees.toString(),
          couleur: Colors.green,
          icone:
          Icons.check_circle,
        ),
      ),
    ],
  ),

  const SizedBox(height: 24),

  Expanded(
    child: interventions.isEmpty
        ? const Center(
      child: Text(
        "Aucune intervention enregistrée.",
      ),
    )
        : ListView.builder(
      itemCount:
      interventions.length,

      itemBuilder:
          (context, index) {
        final intervention =
        interventions[
        index];

        return Card(
          margin:
          const EdgeInsets.only(
            bottom: 16,
          ),

          child: InkWell(
            borderRadius:
            BorderRadius
                .circular(
              12,
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      InterventionDetailsPage(
                        intervention:
                        intervention,
                      ),
                ),
              );
            },

            child: ListTile(
              leading:
              CircleAvatar(
                child: Text(
                  intervention
                      .numero
                      .substring(
                    intervention
                        .numero
                        .length -
                        2,
                  ),
                ),
              ),

              title: Text(
                intervention
                    .clientNom,
              ),

              subtitle: Text(
                "${intervention.numero}\n"
                    "${intervention.agent} • ${intervention.heureDebut}",
              ),

              isThreeLine: true,

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Chip(
                    label: Text(
                      intervention.statut,
                    ),
                  ),

                  PopupMenuButton<String>(
                    onSelected: (value) async {

                      switch (value) {

                        case 'details':

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  InterventionDetailsPage(
                                    intervention: intervention,
                                  ),
                            ),
                          );

                          break;

                        case 'edit':

                          final resultat =
                          await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddInterventionPage(
                                    isEdition: true,
                                    intervention: intervention,
                                  ),
                            ),
                          );

                          if (resultat == true) {
                            await ref
                                .read(
                              interventionProvider.notifier,
                            )
                                .rafraichir();
                          }

                          break;

                        case 'delete':

                          final confirmer = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text(
                                'Confirmation',
                              ),
                              content: Text(
                                'Voulez-vous vraiment supprimer '
                                    'l\'intervention ${intervention.numero} ?',
                              ),
                              actions: [

                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      dialogContext,
                                      false,
                                    );
                                  },
                                  child: const Text(
                                    'Annuler',
                                  ),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      dialogContext,
                                      true,
                                    );
                                  },
                                  child: const Text(
                                    'Supprimer',
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmer == true) {

                            await ref
                                .read(interventionProvider.notifier)
                                .supprimerIntervention(
                              intervention.id,
                            );

                            await ref
                                .read(interventionProvider.notifier)
                                .rafraichir();
                          }

                          break;
                      }
                    },

                    itemBuilder: (context) => const [

                      PopupMenuItem(
                        value: 'details',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('Voir les détails'),
                        ),
                      ),

                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Modifier'),
                        ),
                      ),

                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Supprimer'),
                        ),
                      ),
                    ],
                  ),
                ],
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
),
);
},
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
              backgroundColor: couleur.withValues(
                alpha: 0.15,
              ),
              child: Icon(
                icone,
                color: couleur,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    valeur,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    titre,
                    overflow:
                    TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}