import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = <_ActivityItem>[
      const _ActivityItem(
        icon: Icons.person_add_alt_1_rounded,
        color: Colors.blue,
        title: "Nouveau client enregistré",
        subtitle: "Mamadou Ndiaye",
        time: "Il y a 10 min",
      ),
      const _ActivityItem(
        icon: Icons.pets_rounded,
        color: Colors.green,
        title: "Nouveau mouton ajouté",
        subtitle: "Bergerie de Grand-Yoff",
        time: "09:15",
      ),
      const _ActivityItem(
        icon: Icons.medical_services_rounded,
        color: Colors.orange,
        title: "Intervention terminée",
        subtitle: "Lavage et désinfection",
        time: "08:40",
      ),
      const _ActivityItem(
        icon: Icons.favorite_rounded,
        color: Colors.pink,
        title: "Nouvelle gestation",
        subtitle: "Femelle enregistrée",
        time: "Hier",
      ),
      const _ActivityItem(
        icon: Icons.payments_rounded,
        color: Colors.red,
        title: "Paiement reçu",
        subtitle: "Abonnement Confort",
        time: "Hier",
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.history_rounded,
                color: Color(0xFF0B6E4F),
              ),
              SizedBox(width: 10),
              Text(
                "Activités récentes",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          ...List.generate(
            activities.length,
                (index) {
              final activity = activities[index];

              return Column(
                children: [
                  _ActivityTile(activity: activity),
                  if (index != activities.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 26),
                      child: Divider(height: 28),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
  });

  final _ActivityItem activity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: activity.color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            activity.icon,
            color: activity.color,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activity.subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
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
            color: Colors.grey.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            activity.time,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}