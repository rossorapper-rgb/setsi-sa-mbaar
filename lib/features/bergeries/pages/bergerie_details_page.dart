import 'package:flutter/material.dart';

import '../../../core/widgets/app_back_bar.dart';
import '../models/bergerie_model.dart';
import '../../moutons/pages/moutons_page.dart';

class BergerieDetailsPage extends StatelessWidget {
  final BergerieModel bergerie;

  const BergerieDetailsPage({
    super.key,
    required this.bergerie,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackBar(
        title: "Détails de la bergerie",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      child: Icon(
                        Icons.home_work,
                        size: 35,
                      ),
                    ),
                    const SizedBox(width: 20),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bergerie.nom,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text("📍 ${bergerie.adresse}"),
                          Text("👤 ${bergerie.responsable}"),
                          Text("📞 ${bergerie.telephone}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            _menuCard(
              context,
              icon: Icons.pets,
              title: "Moutons",
              subtitle: "Gérer les moutons de cette bergerie",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MoutonsPage(
                      bergerie: bergerie,
                    ),
                  ),
                );
              },
            ),

            _menuCard(
              context,
              icon: Icons.medical_services,
              title: "Interventions",
              subtitle: "Historique des interventions",
            ),

            _menuCard(
              context,
              icon: Icons.calendar_month,
              title: "Planning",
              subtitle: "Calendrier des visites",
            ),

            _menuCard(
              context,
              icon: Icons.bar_chart,
              title: "Statistiques",
              subtitle: "Indicateurs de la bergerie",
            ),

            _menuCard(
              context,
              icon: Icons.settings,
              title: "Paramètres",
              subtitle: "Configuration",
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        VoidCallback? onTap,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap ??
                () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$title disponible prochainement"),
                ),
              );
            },
      ),
    );
  }
}