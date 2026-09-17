import 'package:flutter/material.dart';

import '../../moutons/models/mouton_model.dart';
import '../models/gestation_model.dart';

class GestationDashboard extends StatelessWidget {
  final List<GestationModel> gestations;
  final List<MoutonModel> moutons;

  final VoidCallback onVoirToutes;
  final void Function(GestationModel) onOuvrirFiche;
  final void Function(GestationModel) onModifier;
  final void Function(GestationModel) onMiseBas;

  const GestationDashboard({
    super.key,
    required this.gestations,
    required this.moutons,
    required this.onVoirToutes,
    required this.onOuvrirFiche,
    required this.onModifier,
    required this.onMiseBas,
  });

  @override
  Widget build(BuildContext context) {
    if (gestations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Aucune gestation enregistrée.',
            ),
          ),
        ),
      );
    }

    final rappels = gestations.where((g) {
      return !g.miseBasEffectuee && (g.procheDeLaMiseBas || g.estEnRetard);
    }).toList();

    return Column(
      children: [
        if (rappels.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_active_rounded,
                        color: rappels.any((g) => g.estEnRetard)
                            ? Colors.red
                            : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Rappels',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...rappels.map(_rappelTile),
                ],
              ),
            ),
          ),
        Card(
          child: Column(
            children: gestations.map((g) {
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.pets),
                ),
                title: InkWell(
                  onTap: () => onOuvrirFiche(g),
                  child: Text(
                    g.nomFemelle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                subtitle: Text(
                  'Saillie : '
                      '${g.dateSaillie.day}/${g.dateSaillie.month}/${g.dateSaillie.year}\n'
                      'Mise bas prévue : '
                      '${g.dateProbableMiseBas.day}/${g.dateProbableMiseBas.month}/${g.dateProbableMiseBas.year}',
                ),
                isThreeLine: true,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _rappelTile(GestationModel g) {
    final retard = g.estEnRetard;
    final jours = g.joursRestants;

    String message;
    if (retard) {
      final joursRetard = DateTime.now().difference(g.dateProbableMiseBas).inDays;
      message = joursRetard <= 0
          ? 'Mise bas prévue aujourd’hui'
          : 'Mise bas en retard de $joursRetard jour${joursRetard > 1 ? 's' : ''}';
    } else if (jours <= 0) {
      message = 'Mise bas prévue aujourd’hui';
    } else if (jours == 1) {
      message = 'Mise bas prévue demain';
    } else {
      message = 'Mise bas prévue dans $jours jours';
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        retard ? Icons.warning_rounded : Icons.event_available_rounded,
        color: retard ? Colors.red : Colors.orange,
      ),
      title: Text(
        g.nomFemelle,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(message),
      onTap: () => onOuvrirFiche(g),
    );
  }
}
