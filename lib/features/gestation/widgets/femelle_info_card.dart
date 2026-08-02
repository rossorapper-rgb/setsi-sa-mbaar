import 'package:flutter/material.dart';

import '../../moutons/models/mouton_model.dart';

class FemelleInfoCard extends StatelessWidget {
  final MoutonModel? femelle;

  const FemelleInfoCard({
    super.key,
    required this.femelle,
  });

  @override
  Widget build(BuildContext context) {
    if (femelle == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pets, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Femelle gestante",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            _info(
              "Nom",
              femelle!.nom,
            ),

            _info(
              "Identification",
              femelle!.numeroIdentification,
            ),

            _info(
              "Race",
              femelle!.race,
            ),

            if (femelle!.dateNaissance != null)
              _info(
                "Naissance",
                "${femelle!.dateNaissance!.day}/"
                    "${femelle!.dateNaissance!.month}/"
                    "${femelle!.dateNaissance!.year}",
              ),
          ],
        ),
      ),
    );
  }

  static Widget _info(
      String titre,
      String valeur,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              titre,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(valeur),
          ),
        ],
      ),
    );
  }
}