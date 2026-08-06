import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InterventionTraitementSection extends StatelessWidget {
  final bool traitementEnCours;

  final TextEditingController maladieController;
  final TextEditingController recommandationsController;

  final DateTime? finTraitement;

  final ValueChanged<bool> onTraitementChanged;
  final VoidCallback onChoisirDate;

  const InterventionTraitementSection({
    super.key,
    required this.traitementEnCours,
    required this.maladieController,
    required this.recommandationsController,
    required this.finTraitement,
    required this.onTraitementChanged,
    required this.onChoisirDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              "Traitement",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            CheckboxListTile(
              value: traitementEnCours,
              title: const Text(
                "Traitement en cours",
              ),
              controlAffinity:
              ListTileControlAffinity.leading,
              onChanged: (value) {
                onTraitementChanged(
                  value ?? false,
                );
              },
            ),

            if (traitementEnCours) ...[
              const SizedBox(height: 16),

              TextFormField(
                controller: maladieController,
                decoration: const InputDecoration(
                  labelText: "Maladie",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.healing),
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                ),
                title: const Text(
                  "Fin du traitement",
                ),
                subtitle: Text(
                  finTraitement == null
                      ? "Aucune date sélectionnée"
                      : DateFormat(
                    "dd/MM/yyyy",
                  ).format(finTraitement!),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onChoisirDate,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                recommandationsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText:
                  "Recommandations",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon:
                  Icon(Icons.notes),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}