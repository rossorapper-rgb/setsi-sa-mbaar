import 'package:flutter/material.dart';

import '../models/gestation_model.dart';

class GestationProgress extends StatelessWidget {
  final GestationModel gestation;

  const GestationProgress({
    super.key,
    required this.gestation,
  });

  @override
  Widget build(BuildContext context) {
    final double progression =
        (gestation.joursGestation / 150).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progression de la gestation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progression,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${gestation.joursGestation} jours'),
                Text('${(progression * 100).toStringAsFixed(0)} %'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${gestation.joursRestants} jour(s) restant(s)',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
