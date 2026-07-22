import 'package:flutter/material.dart';

import '../../interventions/models/intervention_model.dart';
import 'intervention_tile.dart';

class CalendarDayCard extends StatelessWidget {
  final DateTime date;
  final List<InterventionModel> interventions;
  final void Function(InterventionModel)? onInterventionTap;

  const CalendarDayCard({
    super.key,
    required this.date,
    required this.interventions,
    this.onInterventionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event),
                const SizedBox(width: 8),
                Text(
                  "Interventions du ${date.day}/${date.month}/${date.year}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (interventions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Aucune intervention prévue",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...interventions.map(
                    (intervention) => InterventionTile(
                  intervention: intervention,
                  onTap: () =>
                      onInterventionTap?.call(intervention),
                ),
              ),
          ],
        ),
      ),
    );
  }
}