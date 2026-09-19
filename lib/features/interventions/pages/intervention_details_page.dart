import 'package:flutter/material.dart';

import '../models/intervention_model.dart';

class InterventionDetailsPage extends StatelessWidget {
  final InterventionModel intervention;

  const InterventionDetailsPage({
    super.key,
    required this.intervention,
  });

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de l’intervention'),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: 'Intervention',
              icon: Icons.build_circle_outlined,
              children: [
                _InfoRow('Type', intervention.type),
                _InfoRow('Date', _date(intervention.date)),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Animal concerné',
              icon: Icons.pets,
              children: [
                _InfoRow(
                  'Mouton',
                  intervention.moutonNom?.trim().isNotEmpty == true
                      ? intervention.moutonNom!
                      : 'Toute la bergerie',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Observation',
              icon: Icons.description_outlined,
              children: [
                Text(
                  intervention.observation.trim().isEmpty
                      ? 'Aucune observation.'
                      : intervention.observation,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.home_work_outlined, color: primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bergerie : ${intervention.bergerieId}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
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
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primary),
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
            const Divider(height: 28),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
