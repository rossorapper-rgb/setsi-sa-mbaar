import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Activités récentes",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _activityTile(
              Icons.person_add_alt_1,
              Colors.blue,
              "Nouveau client enregistré",
              "Il y a 10 minutes",
            ),

            const Divider(),

            _activityTile(
              Icons.pets,
              Colors.green,
              "Ajout d'un nouveau mouton",
              "Aujourd'hui à 09:15",
            ),

            const Divider(),

            _activityTile(
              Icons.build_circle,
              Colors.orange,
              "Intervention terminée",
              "Aujourd'hui à 08:40",
            ),

            const Divider(),

            _activityTile(
              Icons.payments,
              Colors.red,
              "Paiement reçu",
              "Hier à 17:20",
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityTile(
      IconData icon,
      Color color,
      String title,
      String subtitle,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}