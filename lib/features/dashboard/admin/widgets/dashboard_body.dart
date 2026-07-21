import 'package:flutter/material.dart';

import 'dashboard_chart.dart';
import 'dashboard_stats.dart';
import 'dashboard_today_interventions.dart';

class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    final bool desktop = MediaQuery.of(context).size.width > 1100;

    return Column(
      children: [
        const DashboardStats(),

        const SizedBox(height: 24),

        if (desktop)
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: DashboardChart(),
              ),

              SizedBox(width: 24),

              Expanded(
                child: DashboardTodayInterventions(),
              ),
            ],
          )
        else
          const Column(
            children: [
              DashboardChart(),

              SizedBox(height: 24),

              DashboardTodayInterventions(),
            ],
          ),
      ],
    );
  }
}