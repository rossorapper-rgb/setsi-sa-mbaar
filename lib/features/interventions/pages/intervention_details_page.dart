import 'package:flutter/material.dart';

import '../models/intervention_model.dart';

class InterventionDetailsPage extends StatelessWidget {
  final InterventionModel intervention;

  const InterventionDetailsPage({
    super.key,
    required this.intervention,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(intervention.numero),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
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
                _InfoRow("Nom", intervention.clientNom),
                _InfoRow("Identifiant", intervention.clientId),
                _InfoRow("Nombre de moutons",
                    intervention.nombreMoutons.toString()),
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
                  "${intervention.dateIntervention.day}/${intervention.dateIntervention.month}/${intervention.dateIntervention.year}",
                ),
                _InfoRow("Début", intervention.heureDebut),
                _InfoRow("Fin", intervention.heureFin),
                _InfoRow("Statut", intervention.statut),
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
                  intervention.lavage,
                ),
                _BooleanRow(
                  "Nettoyage bergerie",
                  intervention.nettoyageBergerie,
                ),
                _BooleanRow(
                  "Désinfection",
                  intervention.desinfection,
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
                _InfoRow("Agent", intervention.agent),
                _InfoRow("Véhicule", intervention.vehicule),
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
                Text(intervention.observations),
              ],
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
          Expanded(child: Text(label)),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}