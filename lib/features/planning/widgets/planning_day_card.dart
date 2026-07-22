import 'package:flutter/material.dart';

import '../../interventions/models/intervention_model.dart';
import '../../interventions/pages/intervention_details_page.dart';

class PlanningDayCard extends StatelessWidget {
  final DateTime selectedDate;
  final List<InterventionModel> interventions;

  const PlanningDayCard({
    super.key,
    required this.selectedDate,
    required this.interventions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_note),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Interventions du ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (interventions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Aucune intervention programmée",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: interventions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final intervention = interventions[index];

                  return Card(
                    elevation: 0,
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          intervention.numero.substring(
                            intervention.numero.length - 2,
                          ),
                        ),
                      ),
                      title: Text(intervention.clientNom),
                      subtitle: Text(
                        "${intervention.heureDebut} • ${intervention.agent}",
                      ),
                      trailing: Chip(
                        label: Text(intervention.statut),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InterventionDetailsPage(
                              intervention: intervention,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}