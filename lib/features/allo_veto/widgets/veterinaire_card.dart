import 'package:flutter/material.dart';

import '../models/veterinaire_model.dart';

class VeterinaireCard extends StatelessWidget {
  const VeterinaireCard({
    super.key,
    required this.veterinaire,
    this.onCall,
  });

  final VeterinaireModel veterinaire;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                  primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: primary,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Text(
                    veterinaire.nom,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    veterinaire.region,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.phone,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    veterinaire.telephone,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 14,
                  color: veterinaire.disponible
                      ? Colors.green
                      : Colors.red,
                ),

                const SizedBox(width: 8),

                Text(
                  veterinaire.disponible
                      ? "Disponible"
                      : "Indisponible",
                  style: TextStyle(
                    color: veterinaire.disponible
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: veterinaire.disponible
                    ? onCall
                    : null,
                icon: const Icon(Icons.call),
                label: const Text(
                  "APPELER",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}