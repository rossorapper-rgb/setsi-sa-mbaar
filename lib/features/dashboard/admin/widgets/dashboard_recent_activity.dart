import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: const Row(
        children: [
          Icon(Icons.history_rounded),
          SizedBox(width: 12),
          Expanded(child: Text("Aucune activité administrative récente.", style: TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
