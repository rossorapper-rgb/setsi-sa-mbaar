import 'package:flutter/material.dart';

import '../models/abonnement_model.dart';

class AbonnementStats extends StatelessWidget {
  final List<AbonnementModel> abonnements;

  const AbonnementStats({
    super.key,
    required this.abonnements,
  });

  @override
  Widget build(BuildContext context) {
    final total = abonnements.length;

    final actifs =
        abonnements.where((a) => a.statut == 'Actif').length;

    final attente =
        abonnements.where((a) => a.statut == 'En attente').length;

    final expires =
        abonnements.where((a) => a.statut == 'Expiré').length;

    final chiffreAffaires = abonnements.fold<double>(
      0,
      (sum, a) => sum + a.montant,
    );

    final resteEncaisser = abonnements.fold<double>(
      0,
      (sum, a) => sum + a.resteAPayer,
    );

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildCard(
          "Total",
          total.toString(),
          Icons.subscriptions,
          Colors.blue,
        ),
        _buildCard(
          "Actifs",
          actifs.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildCard(
          "En attente",
          attente.toString(),
          Icons.schedule,
          Colors.orange,
        ),
        _buildCard(
          "Expirés",
          expires.toString(),
          Icons.cancel,
          Colors.red,
        ),
        _buildCard(
          "CA",
          "${chiffreAffaires.toStringAsFixed(0)} FCFA",
          Icons.payments,
          Colors.teal,
        ),
        _buildCard(
          "À encaisser",
          "${resteEncaisser.toStringAsFixed(0)} FCFA",
          Icons.account_balance_wallet,
          Colors.deepPurple,
        ),
      ],
    );
  }

  Widget _buildCard(
    String titre,
    String valeur,
    IconData icon,
    Color couleur,
  ) {
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: couleur, size: 32),
              const SizedBox(height: 10),
              Text(
                valeur,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                titre,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
