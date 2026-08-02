import 'package:flutter/material.dart';

import '../../moutons/models/mouton_model.dart';

class BelierInfoCard extends StatelessWidget {
  final MoutonModel? belier;

  const BelierInfoCard({
    super.key,
    required this.belier,
  });

  @override
  Widget build(BuildContext context) {
    if (belier == null) {
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
                Icon(Icons.pets, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Bélier sélectionné",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            _ligne(
              "Nom",
              belier!.nom,
            ),

            _ligne(
              "Identification",
              belier!.numeroIdentification,
            ),

            _ligne(
              "Race",
              belier!.race,
            ),

            if (belier!.dateNaissance != null)
              _ligne(
                "Naissance",
                "${belier!.dateNaissance!.day}/"
                    "${belier!.dateNaissance!.month}/"
                    "${belier!.dateNaissance!.year}",
              ),
          ],
        ),
      ),
    );
  }

  static Widget _ligne(
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