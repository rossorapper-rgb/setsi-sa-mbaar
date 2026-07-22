import 'package:flutter/material.dart';

import '../../interventions/models/intervention_model.dart';

class InterventionTile extends StatelessWidget {
  final InterventionModel intervention;
  final VoidCallback? onTap;

  const InterventionTile({
    super.key,
    required this.intervention,
    this.onTap,
  });

  Color _statusColor() {
    switch (intervention.statut) {
      case 'Planifiée':
        return Colors.orange;

      case 'En cours':
        return Colors.blue;

      case 'Terminée':
        return Colors.green;

      case 'Annulée':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon() {
    switch (intervention.statut) {
      case 'Planifiée':
        return Icons.schedule;

      case 'En cours':
        return Icons.play_circle_fill;

      case 'Terminée':
        return Icons.check_circle;

      case 'Annulée':
        return Icons.cancel;

      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(
                  _statusIcon(),
                  color: color,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      intervention.numero,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      intervention.clientNom,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${intervention.heureDebut} → ${intervention.heureFin}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            intervention.agent,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  intervention.statut,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}