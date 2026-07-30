import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';

class DashboardChart extends StatelessWidget {
  const DashboardChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Évolution des interventions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: Center(
                  child: Icon(
                    Icons.bar_chart,
                    size: 90,
                    color: Colors.green.shade400,
                  ),
                ),
              ),

              const Text(
                "Le graphique sera affiché ici.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}