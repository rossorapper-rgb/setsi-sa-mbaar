import 'package:flutter/material.dart';

import '../models/abonnement_model.dart';

class AbonnementCard extends StatelessWidget {
  final AbonnementModel abonnement;

  const AbonnementCard({
    super.key,
    required this.abonnement,
  });

  Color _statusColor() {
    switch (abonnement.statut) {
      case 'Actif':
        return Colors.green;
      case 'En attente':
        return Colors.orange;
      case 'Expiré':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor().withOpacity(0.15),
          child: Icon(Icons.card_membership, color: _statusColor()),
        ),
        title: Text(
          abonnement.clientNom,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("N° : ${abonnement.numero}"),
            Text("Pack : ${abonnement.pack}"),
            Text("Montant : ${abonnement.montant.toStringAsFixed(0)} FCFA"),
            Text("Reste : ${abonnement.resteAPayer.toStringAsFixed(0)} FCFA"),
            Text(
              "Échéance : ${abonnement.dateFin.day}/${abonnement.dateFin.month}/${abonnement.dateFin.year}",
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor(),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            abonnement.statut,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          // Navigation vers abonnement_details_page.dart
        },
      ),
    );
  }
}
