import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;

  const CalendarHeader({
    super.key,
    required this.focusedDay,
  });

  @override
  Widget build(BuildContext context) {
    final mois = DateFormat(
      "MMMM yyyy",
      "fr_FR",
    ).format(focusedDay);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(width: 12),
              Text(
                "Calendrier des interventions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            mois[0].toUpperCase() + mois.substring(1),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}