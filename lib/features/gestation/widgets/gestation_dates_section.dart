import 'package:flutter/material.dart';

class GestationDatesSection extends StatelessWidget {
  final DateTime dateSaillie;
  final DateTime dateProbableMiseBas;
  final VoidCallback onChoisirDate;

  const GestationDatesSection({
    super.key,
    required this.dateSaillie,
    required this.dateProbableMiseBas,
    required this.onChoisirDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dates",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ListTile(
          leading: const Icon(Icons.calendar_month),
          title: const Text("Date de saillie"),
          subtitle: Text(
            "${dateSaillie.day}/${dateSaillie.month}/${dateSaillie.year}",
          ),
          trailing: const Icon(Icons.edit),
          onTap: onChoisirDate,
        ),

        Card(
          child: ListTile(
            leading: const Icon(
              Icons.event_available,
              color: Colors.green,
            ),
            title: const Text(
              "Date probable de mise bas",
            ),
            subtitle: Text(
              "${dateProbableMiseBas.day}/"
                  "${dateProbableMiseBas.month}/"
                  "${dateProbableMiseBas.year}",
            ),
          ),
        ),
      ],
    );
  }
}