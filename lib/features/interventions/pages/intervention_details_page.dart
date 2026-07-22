import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/intervention_model.dart';
import '../providers/intervention_provider.dart';
import 'edit_intervention_page.dart';

class InterventionDetailsPage extends ConsumerWidget {
final InterventionModel intervention;

const InterventionDetailsPage({
super.key,
required this.intervention,
});

@override
Widget build(BuildContext context, WidgetRef ref) {

final interventionCourante = ref.watch(
interventionProvider.select(
(liste) => liste.firstWhere(
(i) => i.id == intervention.id,
orElse: () => intervention,
),
),
);

return Scaffold(
backgroundColor: const Color(0xFFF5F7FA),

appBar: AppBar(
title: Text(interventionCourante.numero),
),

body: SingleChildScrollView(
padding: const EdgeInsets.all(24),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

//==========================
// CLIENT
//==========================

_SectionCard(
title: "Client",
icon: Icons.person,
children: [
_InfoRow("Nom", interventionCourante.clientNom),
_InfoRow("Identifiant", interventionCourante.clientId),
_InfoRow(
"Nombre de moutons",
interventionCourante.nombreMoutons.toString(),
),
],
),

const SizedBox(height: 20),

//==========================
// PLANIFICATION
//==========================

_SectionCard(
title: "Planification",
icon: Icons.calendar_month,
children: [
_InfoRow(
"Date",
"${interventionCourante.dateIntervention.day}/${interventionCourante.dateIntervention.month}/${interventionCourante.dateIntervention.year}",
),
_InfoRow(
"Début",
interventionCourante.heureDebut,
),
_InfoRow(
"Fin",
interventionCourante.heureFin,
),
_InfoRow(
"Statut",
interventionCourante.statut,
),
],
),

const SizedBox(height: 20),

//==========================
// PRESTATIONS
//==========================

_SectionCard(
title: "Prestations",
icon: Icons.cleaning_services,
children: [
_BooleanRow(
"Lavage",
interventionCourante.lavage,
),
_BooleanRow(
"Nettoyage bergerie",
interventionCourante.nettoyageBergerie,
),
_BooleanRow(
"Désinfection",
interventionCourante.desinfection,
),
],
),

const SizedBox(height: 20),

//==========================
// RESSOURCES
//==========================

_SectionCard(
title: "Ressources",
icon: Icons.groups,
children: [
_InfoRow(
"Agent",
interventionCourante.agent,
),
_InfoRow(
"Véhicule",
interventionCourante.vehicule,
),
],
),

const SizedBox(height: 20),

//==========================
// OBSERVATIONS
//==========================

_SectionCard(
title: "Observations",
icon: Icons.description,
children: [
Text(interventionCourante.observations),
],
),

const SizedBox(height: 30),

  SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      icon: const Icon(Icons.edit),
      label: const Text("Modifier l'intervention"),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditInterventionPage(
              intervention: interventionCourante,
            ),
          ),
        );
      },
    ),
  ),

  const SizedBox(height: 12),

  SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.red,
      ),
      icon: const Icon(Icons.delete),
      label: const Text("Supprimer l'intervention"),
      onPressed: () async {
        final confirmation = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirmation"),
            content: const Text(
              "Voulez-vous vraiment supprimer cette intervention ?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Annuler"),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Supprimer"),
              ),
            ],
          ),
        );

        if (confirmation == true) {
          ref
              .read(interventionProvider.notifier)
              .deleteIntervention(interventionCourante.id);

          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
    ),
  ),

],
),
),
);
}
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _BooleanRow extends StatelessWidget {
  final String label;
  final bool value;

  const _BooleanRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}