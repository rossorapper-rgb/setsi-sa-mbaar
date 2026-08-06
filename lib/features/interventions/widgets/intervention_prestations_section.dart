import 'package:flutter/material.dart';

class InterventionPrestationsSection extends StatelessWidget {
  final bool lavage;
  final bool nettoyageBergerie;
  final bool desinfection;
  final bool vermifugation;

  final String produitVermifuge;
  final DateTime? prochaineVermifugation;

  final ValueChanged<bool> onLavageChanged;
  final ValueChanged<bool> onNettoyageChanged;
  final ValueChanged<bool> onDesinfectionChanged;
  final ValueChanged<bool> onVermifugationChanged;

  final VoidCallback onChoisirDate;

  final TextEditingController produitController;

  const InterventionPrestationsSection({
    super.key,
    required this.lavage,
    required this.nettoyageBergerie,
    required this.desinfection,
    required this.vermifugation,
    required this.produitVermifuge,
    required this.prochaineVermifugation,
    required this.onLavageChanged,
    required this.onNettoyageChanged,
    required this.onDesinfectionChanged,
    required this.onVermifugationChanged,
    required this.onChoisirDate,
    required this.produitController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              "Prestations",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            CheckboxListTile(
              value: lavage,
              title: const Text("Lavage"),
              controlAffinity:
              ListTileControlAffinity.leading,
              onChanged: (v) =>
                  onLavageChanged(v ?? false),
            ),

            CheckboxListTile(
              value: nettoyageBergerie,
              title: const Text(
                "Nettoyage de la bergerie",
              ),
              controlAffinity:
              ListTileControlAffinity.leading,
              onChanged: (v) =>
                  onNettoyageChanged(v ?? false),
            ),

            CheckboxListTile(
              value: desinfection,
              title: const Text("Désinfection"),
              controlAffinity:
              ListTileControlAffinity.leading,
              onChanged: (v) =>
                  onDesinfectionChanged(v ?? false),
            ),

            CheckboxListTile(
              value: vermifugation,
              title: const Text("Vermifugation"),
              controlAffinity:
              ListTileControlAffinity.leading,
              onChanged: (v) =>
                  onVermifugationChanged(v ?? false),
            ),

            if (vermifugation) ...[
              const SizedBox(height: 16),

              TextFormField(
                controller: produitController,
                decoration: const InputDecoration(
                  labelText:
                  "Produit vermifuge",
                  border: OutlineInputBorder(),
                  prefixIcon:
                  Icon(Icons.medication),
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                ),
                title: const Text(
                  "Prochaine vermifugation",
                ),
                subtitle: Text(
                  prochaineVermifugation == null
                      ? "Aucune date sélectionnée"
                      : "${prochaineVermifugation!.day.toString().padLeft(2, '0')}/"
                      "${prochaineVermifugation!.month.toString().padLeft(2, '0')}/"
                      "${prochaineVermifugation!.year}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onChoisirDate,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}