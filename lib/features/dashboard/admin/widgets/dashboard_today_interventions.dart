import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../models/intervention_model.dart';

class InterventionCard extends StatelessWidget {
  final InterventionModel intervention;

  const InterventionCard({
    super.key,
    required this.intervention,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;

    switch (intervention.statut) {
      case "Terminée":
        statusColor = Colors.green;
        break;

      case "En cours":
        statusColor = Colors.orange;
        break;

      default:
        statusColor = Colors.blue;
    }

    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Text(intervention.heure),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intervention.client,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(intervention.quartier),

                Text(intervention.service),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              intervention.statut,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}