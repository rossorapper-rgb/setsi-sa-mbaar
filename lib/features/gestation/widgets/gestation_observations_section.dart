import 'package:flutter/material.dart';

class GestationObservationsSection extends StatelessWidget {
  final TextEditingController controller;

  const GestationObservationsSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Observations",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Ajouter une observation...",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}