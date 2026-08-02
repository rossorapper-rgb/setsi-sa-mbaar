import 'package:flutter/material.dart';

import '../../moutons/models/mouton_model.dart';
import 'femelle_info_card.dart';

class GestationFemelleSection extends StatelessWidget {
  final List<MoutonModel> brebis;
  final MoutonModel? femelleSelectionnee;
  final ValueChanged<MoutonModel?> onChanged;

  const GestationFemelleSection({
    super.key,
    required this.brebis,
    required this.femelleSelectionnee,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Femelle gestante",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<MoutonModel>(
          value: femelleSelectionnee,
          decoration: const InputDecoration(
            labelText: "Brebis",
            border: OutlineInputBorder(),
          ),
          hint: const Text("Sélectionner une femelle"),
          items: brebis.map((e) {
            return DropdownMenuItem<MoutonModel>(
              value: e,
              child: Text(
                "${e.nom} • ${e.numeroIdentification}",
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),

        const SizedBox(height: 12),

        FemelleInfoCard(
          femelle: femelleSelectionnee,
        ),
      ],
    );
  }
}