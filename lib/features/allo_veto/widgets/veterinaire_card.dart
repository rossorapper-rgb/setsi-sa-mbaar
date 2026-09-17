import 'package:flutter/material.dart';

import '../models/veterinaire_model.dart';

class VeterinaireCard extends StatelessWidget {
  const VeterinaireCard({
    super.key,
    required this.veterinaire,
    this.onCall,
    this.onEdit,
    this.onDelete,
  });

  final VeterinaireModel veterinaire;
  final VoidCallback? onCall;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: primary.withValues(alpha: 0.12),
              child: Icon(
                Icons.medical_services_rounded,
                color: primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    veterinaire.nom,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    veterinaire.telephone,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Appeler',
              onPressed: onCall,
              icon: const Icon(Icons.call_rounded),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'modifier') {
                  onEdit?.call();
                } else if (value == 'supprimer') {
                  onDelete?.call();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'modifier',
                  child: Text('Modifier'),
                ),
                PopupMenuItem(
                  value: 'supprimer',
                  child: Text('Supprimer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}