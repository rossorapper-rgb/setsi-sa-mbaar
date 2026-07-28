import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/abonnement_model.dart';

class AbonnementDetailsPage extends StatelessWidget {
  final AbonnementModel abonnement;

  const AbonnementDetailsPage({
    super.key,
    required this.abonnement,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat("#,##0", "fr_FR");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de l'abonnement"),
        actions: [
          IconButton(
            onPressed: () {
              // TODO Modifier
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              // TODO Supprimer
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.card_membership,
                    size: 60,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    abonnement.clientNom,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(abonnement.numero),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _ligne("Client", abonnement.clientNom),
          _ligne("Bergerie", abonnement.bergerieNom),
          _ligne("Pack", abonnement.pack),
          _ligne("Montant",
              "${format.format(abonnement.montant)} FCFA"),
          _ligne("Payé",
              "${format.format(abonnement.montantPaye)} FCFA"),
          _ligne("Reste",
              "${format.format(abonnement.resteAPayer)} FCFA"),
          _ligne("Statut", abonnement.statut),
          _ligne(
            "Début",
            DateFormat("dd/MM/yyyy").format(abonnement.dateDebut),
          ),
          _ligne(
            "Fin",
            DateFormat("dd/MM/yyyy").format(abonnement.dateFin),
          ),
          _ligne("Observations", abonnement.observations.isEmpty
              ? "-"
              : abonnement.observations),
        ],
      ),
    );
  }

  Widget _ligne(String titre, String valeur) {
    return Card(
      child: ListTile(
        title: Text(titre),
        subtitle: Text(valeur),
      ),
    );
  }
}
