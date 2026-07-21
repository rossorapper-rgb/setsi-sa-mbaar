import 'package:flutter/material.dart';

import '../models/client_model.dart';

class ClientCard extends StatelessWidget {
  final ClientModel client;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsapp;

  const ClientCard({
    super.key,
    required this.client,
    this.onView,
    this.onEdit,
    this.onCall,
    this.onWhatsapp,
  });

  Color get abonnementColor {
    switch (client.abonnement.toLowerCase()) {
      case "prestige":
        return Colors.orange;

      case "confort":
        return Colors.blue;

      case "essentiel":
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  Color get statutColor {
    return client.actif ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //----------------------------------
            // Entête
            //----------------------------------

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(
                    Icons.person,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.nom,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(client.telephone),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(client.quartier),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(
                      backgroundColor: abonnementColor.withOpacity(.15),
                      side: BorderSide.none,
                      label: Text(
                        client.abonnement,
                        style: TextStyle(
                          color: abonnementColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statutColor.withOpacity(.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: statutColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            client.statut,
                            style: TextStyle(
                              color: statutColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 24),

            //----------------------------------
            // Statistiques
            //----------------------------------

            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.home_work,
                    label: "Troupeaux",
                    value: client.nombreTroupeaux.toString(),
                  ),
                ),

                Expanded(
                  child: _InfoTile(
                    icon: Icons.pets,
                    label: "Moutons",
                    value: client.nombreMoutons.toString(),
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            //----------------------------------
            // Actions
            //----------------------------------

            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility),
                  label: const Text("Voir"),
                ),

                const SizedBox(width: 10),

                FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text("Modifier"),
                ),

                const Spacer(),

                IconButton(
                  tooltip: "Appeler",
                  onPressed: onCall,
                  icon: const Icon(Icons.call),
                ),

                IconButton(
                  tooltip: "WhatsApp",
                  onPressed: onWhatsapp,
                  icon: const Icon(Icons.chat),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}