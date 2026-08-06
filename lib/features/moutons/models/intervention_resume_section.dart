import 'package:flutter/material.dart';

import '../../bergeries/models/bergerie_model.dart';
import '../../clients/models/client_model.dart';
import '../../moutons/models/mouton_model.dart';

class InterventionResumeSection extends StatelessWidget {
  final ClientModel? client;
  final BergerieModel? bergerie;
  final List<MoutonModel> moutonsSelectionnes;

  final bool lavage;
  final bool nettoyageBergerie;
  final bool desinfection;
  final bool vermifugation;

  final bool traitementEnCours;

  const InterventionResumeSection({
    super.key,
    required this.client,
    required this.bergerie,
    required this.moutonsSelectionnes,
    required this.lavage,
    required this.nettoyageBergerie,
    required this.desinfection,
    required this.vermifugation,
    required this.traitementEnCours,
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
              "Résumé de l'intervention",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _ResumeLigne(
              titre: "Client",
              valeur: client?.nom ?? "-",
            ),

            _ResumeLigne(
              titre: "Bergerie",
              valeur: bergerie?.nom ?? "-",
            ),

            _ResumeLigne(
              titre: "Moutons sélectionnés",
              valeur:
              "${moutonsSelectionnes.length}",
            ),

            const Divider(),

            const Text(
              "Prestations",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            if (lavage)
              const Text("• Lavage"),

            if (nettoyageBergerie)
              const Text(
                "• Nettoyage de la bergerie",
              ),

            if (desinfection)
              const Text("• Désinfection"),

            if (vermifugation)
              const Text("• Vermifugation"),

            if (!lavage &&
                !nettoyageBergerie &&
                !desinfection &&
                !vermifugation)
              const Text(
                "Aucune prestation sélectionnée.",
              ),

            const Divider(),

            _ResumeLigne(
              titre: "Traitement",
              valeur: traitementEnCours
                  ? "Oui"
                  : "Non",
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumeLigne extends StatelessWidget {
  final String titre;
  final String valeur;

  const _ResumeLigne({
    required this.titre,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              titre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(valeur),
          ),
        ],
      ),
    );
  }
}