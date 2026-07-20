import 'package:flutter/material.dart';

import 'stat_card.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    int crossAxisCount = 4;

    if (width < 1200) {
      crossAxisCount = 2;
    }

    if (width < 700) {
      crossAxisCount = 1;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.45,
      children: const [
        StatCard(
          icon: Icons.people,
          title: "Clients",
          value: "128",
          evolution: "+12%",
          color: Colors.blue,
        ),

        StatCard(
          icon: Icons.pets,
          title: "Moutons",
          value: "325",
          evolution: "+8%",
          color: Colors.green,
        ),

        StatCard(
          icon: Icons.build_circle,
          title: "Interventions",
          value: "42",
          evolution: "+5%",
          color: Colors.orange,
        ),

        StatCard(
          icon: Icons.payments,
          title: "Revenus",
          value: "3,2 M FCFA",
          evolution: "+18%",
          color: Colors.red,
        ),
      ],
    );
  }
}