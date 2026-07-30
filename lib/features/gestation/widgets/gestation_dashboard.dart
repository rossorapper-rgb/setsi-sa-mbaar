import 'package:flutter/material.dart';

import '../../moutons/models/mouton_model.dart';
import '../models/gestation_model.dart';

class GestationDashboard extends StatelessWidget {
  final List<GestationModel> gestations;
  final List<MoutonModel> moutons;

  final VoidCallback onVoirToutes;
  final void Function(GestationModel) onOuvrirFiche;
  final void Function(GestationModel) onModifier;
  final void Function(GestationModel) onMiseBas;

  const GestationDashboard({
    super.key,
    required this.gestations,
    required this.moutons,
    required this.onVoirToutes,
    required this.onOuvrirFiche,
    required this.onModifier,
    required this.onMiseBas,
  });

  @override
  Widget build(BuildContext context) {
    if (gestations.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              "Aucune gestation enregistrée.",
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: gestations.map((g) {
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.pets),
            ),
            title: Text(g.nomFemelle),
            subtitle: Text(
              "Saillie : "
                  "${g.dateSaillie.day}/${g.dateSaillie.month}/${g.dateSaillie.year}",
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'fiche':
                    onOuvrirFiche(g);
                    break;

                  case 'modifier':
                    onModifier(g);
                    break;

                  case 'misebas':
                    onMiseBas(g);
                    break;
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: "fiche",
                  child: Text("Voir la fiche"),
                ),
                PopupMenuItem(
                  value: "modifier",
                  child: Text("Modifier"),
                ),
                PopupMenuItem(
                  value: "misebas",
                  child: Text("Enregistrer la mise bas"),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}