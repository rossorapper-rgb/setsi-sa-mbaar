import 'package:flutter/material.dart';

import '../../bergeries/models/bergerie_model.dart';

class InterventionBergerieSection extends StatelessWidget {
  final List<BergerieModel> bergeries;
  final BergerieModel? bergerieSelectionnee;
  final ValueChanged<BergerieModel?> onBergerieChanged;

  const InterventionBergerieSection({
    super.key,
    required this.bergeries,
    required this.bergerieSelectionnee,
    required this.onBergerieChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (bergeries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.home_work_outlined),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Aucune bergerie trouvée pour ce client.",
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<BergerieModel>(
          value: bergerieSelectionnee,
          decoration: const InputDecoration(
            labelText: "Bergerie",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.home_work),
          ),
          items: bergeries
              .map(
                (bergerie) => DropdownMenuItem(
              value: bergerie,
              child: Text(bergerie.nom),
            ),
          )
              .toList(),
          onChanged: onBergerieChanged,
          validator: (value) {
            if (value == null) {
              return "Veuillez sélectionner une bergerie";
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        if (bergerieSelectionnee != null)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    bergerieSelectionnee!.nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _InfoRow(
                    icon: Icons.location_on,
                    label: "Adresse",
                    value: bergerieSelectionnee!.adresse,
                  ),

                  _InfoRow(
                    icon: Icons.person,
                    label: "Responsable",
                    value: bergerieSelectionnee!.responsable,
                  ),

                  _InfoRow(
                    icon: Icons.phone,
                    label: "Téléphone",
                    value: bergerieSelectionnee!.telephone,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            "$label : ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}