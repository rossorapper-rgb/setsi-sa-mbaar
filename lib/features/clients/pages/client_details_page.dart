import 'package:flutter/material.dart';

import '../models/client_model.dart';
import 'edit_client_page.dart';

class ClientDetailsPage extends StatelessWidget {
  final ClientModel client;

  const ClientDetailsPage({
    super.key,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du client"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
            radius: 45,
            child: Icon(
              Icons.person,
              size: 50,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            client.nom,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          _InfoTile(
            icon: Icons.phone,
            title: "Téléphone",
            value: client.telephone,
          ),

          _InfoTile(
            icon: Icons.location_on,
            title: "Quartier",
            value: client.quartier,
          ),

          _InfoTile(
            icon: Icons.home,
            title: "Adresse",
            value: client.adresse,
          ),

          _InfoTile(
            icon: Icons.home_work,
            title: "Nombre de troupeaux",
            value: client.nombreTroupeaux.toString(),
          ),

          _InfoTile(
            icon: Icons.pets,
            title: "Nombre de moutons",
            value: client.nombreMoutons.toString(),
          ),

          _InfoTile(
            icon: Icons.workspace_premium,
            title: "Abonnement",
            value: client.abonnement,
          ),

          _InfoTile(
            icon: client.actif ? Icons.check_circle : Icons.cancel,
            title: "Statut",
            value: client.actif ? "Actif" : "Inactif",
          ),

          const SizedBox(height: 30),

          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditClientPage(
                    client: client,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text("Modifier"),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text("Retour"),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}