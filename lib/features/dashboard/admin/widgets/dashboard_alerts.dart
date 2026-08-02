import 'package:flutter/material.dart';

class DashboardAlerts extends StatelessWidget {
  const DashboardAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      const _Alert(
        icon: Icons.favorite_rounded,
        color: Colors.pink,
        title: "3 mises bas prévues cette semaine",
        subtitle: "Surveillez les femelles gestantes.",
      ),
      const _Alert(
        icon: Icons.medical_services_rounded,
        color: Colors.orange,
        title: "5 interventions programmées aujourd'hui",
        subtitle: "Préparez les équipes.",
      ),
      const _Alert(
        icon: Icons.workspace_premium_rounded,
        color: Colors.blue,
        title: "2 abonnements arrivent à échéance",
        subtitle: "Contacter les clients concernés.",
      ),
      const _Alert(
        icon: Icons.warning_amber_rounded,
        color: Colors.red,
        title: "Vaccinations à planifier",
        subtitle: "4 moutons sont concernés.",
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF0B6E4F),
              ),
              SizedBox(width: 10),
              Text(
                "Alertes & Priorités",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          ...alerts.map(
                (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _AlertTile(alert: alert),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final _Alert alert;

  const _AlertTile({
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert.color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: alert.color.withValues(alpha: .15),
            child: Icon(
              alert.icon,
              color: alert.color,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  alert.subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: alert.color,
          ),
        ],
      ),
    );
  }
}

class _Alert {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _Alert({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}