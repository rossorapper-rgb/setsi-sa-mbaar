import 'package:flutter/material.dart';

import '../../moutons/models/mouton_model.dart';

class InterventionMoutonsSection extends StatelessWidget {
  final List<MoutonModel> moutons;
  final List<String> moutonsSelectionnes;
  final ValueChanged<List<String>> onSelectionChanged;

  const InterventionMoutonsSection({
    super.key,
    required this.moutons,
    required this.moutonsSelectionnes,
    required this.onSelectionChanged,
  });

  void _toggleToutSelectionner() {
    if (moutonsSelectionnes.length == moutons.length) {
      onSelectionChanged([]);
    } else {
      onSelectionChanged(
        moutons.map((e) => e.id).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (moutons.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.pets),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Aucun mouton dans cette bergerie.",
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            const Text(
              "Moutons concernés",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            CheckboxListTile(
              value: moutonsSelectionnes.length ==
                  moutons.length,
              title: const Text(
                "Tout sélectionner",
              ),
              controlAffinity:
              ListTileControlAffinity.leading,
              onChanged: (_) =>
                  _toggleToutSelectionner(),
            ),

            const Divider(),

            ...moutons.map(
                  (mouton) {

                final selectionne =
                moutonsSelectionnes.contains(
                  mouton.id,
                );

                return CheckboxListTile(
                  value: selectionne,
                  controlAffinity:
                  ListTileControlAffinity.leading,
                  title: Text(mouton.nom),
                  subtitle: Text(
                    "Identification : ${mouton.numeroIdentification}",
                  ),
                  onChanged: (value) {

                    final liste =
                    List<String>.from(
                      moutonsSelectionnes,
                    );

                    if (value == true) {
                      liste.add(mouton.id);
                    } else {
                      liste.remove(mouton.id);
                    }

                    onSelectionChanged(liste);
                  },
                );
              },
            ),

            const Divider(),

            Row(
              children: [

                const Icon(Icons.check_circle),

                const SizedBox(width: 8),

                Text(
                  "${moutonsSelectionnes.length} mouton(s) sélectionné(s)",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}