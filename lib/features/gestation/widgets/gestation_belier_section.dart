
import 'package:flutter/material.dart';

import '../../moutons/models/mouton_model.dart';
import '../pages/add_gestation_page.dart';
import 'belier_info_card.dart';

class GestationBelierSection extends StatelessWidget {
  final TypeBelier typeBelier;
  final MoutonModel? belierSelectionne;
  final List<MoutonModel> beliers;

  final ValueChanged<TypeBelier> onTypeChanged;
  final ValueChanged<MoutonModel?> onBelierChanged;

  final TextEditingController nomBelierController;
  final TextEditingController proprietaireController;

  const GestationBelierSection({
    super.key,
    required this.typeBelier,
    required this.belierSelectionne,
    required this.beliers,
    required this.onTypeChanged,
    required this.onBelierChanged,
    required this.nomBelierController,
    required this.proprietaireController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bélier reproducteur",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        RadioListTile<TypeBelier>(
          value: TypeBelier.troupeau,
          groupValue: typeBelier,
          title: const Text("Bélier du troupeau"),
          onChanged: (v) {
            if (v != null) {
              onTypeChanged(v);
            }
          },
        ),

        RadioListTile<TypeBelier>(
          value: TypeBelier.exterieur,
          groupValue: typeBelier,
          title: const Text("Bélier extérieur"),
          onChanged: (v) {
            if (v != null) {
              onTypeChanged(v);
            }
          },
        ),

        if (typeBelier == TypeBelier.troupeau) ...[
          DropdownButtonFormField<MoutonModel>(
            value: belierSelectionne,
            decoration: const InputDecoration(
              labelText: "Bélier",
              border: OutlineInputBorder(),
            ),
            items: beliers.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(
                  "${e.nom} • ${e.numeroIdentification}",
                ),
              );
            }).toList(),
            onChanged: onBelierChanged,
          ),

          const SizedBox(height: 12),

          BelierInfoCard(
            belier: belierSelectionne,
          ),
        ],

        if (typeBelier == TypeBelier.exterieur) ...[
          TextFormField(
            controller: nomBelierController,
            decoration: const InputDecoration(
              labelText: "Nom du bélier",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: proprietaireController,
            decoration: const InputDecoration(
              labelText: "Propriétaire",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}