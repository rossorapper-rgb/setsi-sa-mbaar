import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';

class DashboardTodayInterventions extends StatelessWidget {
  const DashboardTodayInterventions({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.today,
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  "Interventions du jour",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _item(
              heure: "08:00",
              client: "Aucune intervention",
              statut: "Planifiée",
            ),

            const Divider(),

            _item(
              heure: "--:--",
              client: "Aucune intervention",
              statut: "En attente",
            ),
          ],
        ),
      ),
    );
  }

  Widget _item({
    required String heure,
    required String client,
    required String statut,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Text(
          heure,
          style: const TextStyle(fontSize: 10),
        ),
      ),
      title: Text(client),
      subtitle: Text(statut),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}