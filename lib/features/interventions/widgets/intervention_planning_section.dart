import 'package:flutter/material.dart';

class InterventionPlanningSection extends StatelessWidget {
  final TextEditingController dateController;
  final TextEditingController heureDebutController;
  final TextEditingController heureFinController;
  final TextEditingController agentController;
  final TextEditingController vehiculeController;

  final VoidCallback onChoisirDate;
  final VoidCallback onChoisirHeureDebut;
  final VoidCallback onChoisirHeureFin;

  const InterventionPlanningSection({
    super.key,
    required this.dateController,
    required this.heureDebutController,
    required this.heureFinController,
    required this.agentController,
    required this.vehiculeController,
    required this.onChoisirDate,
    required this.onChoisirHeureDebut,
    required this.onChoisirHeureFin,
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
              "Planning",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Date d'intervention",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(
                  Icons.calendar_month,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onChoisirDate,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller:
                    heureDebutController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Début",
                      border:
                      const OutlineInputBorder(),
                      prefixIcon: const Icon(
                        Icons.access_time,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed:
                        onChoisirHeureDebut,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: TextFormField(
                    controller:
                    heureFinController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Fin",
                      border:
                      const OutlineInputBorder(),
                      prefixIcon: const Icon(
                        Icons.access_time,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed:
                        onChoisirHeureFin,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: agentController,
              decoration: const InputDecoration(
                labelText: "Agent",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return "Veuillez renseigner l'agent";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: vehiculeController,
              decoration: const InputDecoration(
                labelText: "Véhicule",
                border: OutlineInputBorder(),
                prefixIcon:
                Icon(Icons.local_shipping),
              ),
            ),
          ],
        ),
      ),
    );
  }
}