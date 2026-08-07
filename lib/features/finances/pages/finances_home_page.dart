import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

import 'creances_page.dart';
import 'dashboard_financier_page.dart';
import 'paiements_page.dart';
import 'rapports_financiers_page.dart';

class FinancesHomePage extends StatelessWidget {
const FinancesHomePage({
super.key,
});

@override
Widget build(BuildContext context) {
return ResponsivePage(
title: "Finances",

child: GridView.count(
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),

crossAxisCount: 2,

mainAxisSpacing: 16,
crossAxisSpacing: 16,

childAspectRatio: 1.15,

children: [

_menuCard(
context,
icon: Icons.payments_rounded,
couleur: Colors.green,
titre: "Paiements",
sousTitre:
"Consulter et enregistrer",
page: const PaiementsPage(),
),

_menuCard(
context,
icon: Icons.account_balance_wallet_rounded,
couleur: Colors.red,
titre: "Créances",
sousTitre:
"Montants à encaisser",
page: const CreancesPage(),
),

_menuCard(
context,
icon: Icons.dashboard_rounded,
couleur: Colors.indigo,
titre:
"Dashboard",
sousTitre:
"Situation financière",
page:
const DashboardFinancierPage(),
),
  _menuCard(
    context,
    icon: Icons.bar_chart_rounded,
    couleur: Colors.deepPurple,
    titre: "Rapports",
    sousTitre:
    "PDF et Excel",
    page:
    const RapportsFinanciersPage(),
  ),

  _menuCard(
    context,
    icon: Icons.picture_as_pdf_rounded,
    couleur: Colors.orange,
    titre: "Factures",
    sousTitre:
    "Générer les factures",
    onTap: () {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Ouvrez un paiement puis cliquez sur « Générer la facture PDF ».",
          ),
        ),
      );
    },
  ),

  _menuCard(
    context,
    icon: Icons.receipt_long_rounded,
    couleur: Colors.teal,
    titre: "Reçus",
    sousTitre:
    "Générer les reçus",
    onTap: () {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Ouvrez un paiement puis cliquez sur « Générer le reçu PDF ».",
          ),
        ),
      );
    },
  ),

],
),
);
}

Widget _menuCard(
    BuildContext context, {
      required IconData icon,
      required Color couleur,
      required String titre,
      required String sousTitre,
      Widget? page,
      VoidCallback? onTap,
    }) {
  return AppCard(
    child: InkWell(
      borderRadius:
      BorderRadius.circular(12),

      onTap: () {
        if (onTap != null) {
          onTap();
          return;
        }

        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        }
      },

      child: Padding(
        padding:
        const EdgeInsets.all(18),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            CircleAvatar(
              radius: 28,
              backgroundColor:
              couleur.withValues(
                alpha: .15,
              ),

              child: Icon(
                icon,
                color: couleur,
                size: 30,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              sousTitre,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
                fontSize: 13,
              ),
            ),

          ],
        ),
      ),
    ),
  );
}
}
