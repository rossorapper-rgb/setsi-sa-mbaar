import 'package:flutter/material.dart';

class DashboardAlerts extends StatelessWidget {
  const DashboardAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_none_rounded, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          const Expanded(child: Text("Aucune alerte administrative pour le moment.", style: TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
