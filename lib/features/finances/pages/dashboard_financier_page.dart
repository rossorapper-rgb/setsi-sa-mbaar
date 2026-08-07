import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/paiement_model.dart';
import '../providers/paiement_provider.dart';

class DashboardFinancierPage extends ConsumerWidget {
const DashboardFinancierPage({
super.key,
});

@override
Widget build(
BuildContext context,
WidgetRef ref,
) {
final paiementsAsync =
ref.watch(paiementProvider);

return paiementsAsync.when(
loading: () => const Scaffold(
body: Center(
child:
CircularProgressIndicator(),
),
),
error: (e, s) => Scaffold(
appBar: AppBar(
title: const Text(
"Dashboard Financier",
),
),
body: Center(
child: Text(e.toString()),
),
),
data: (
List<PaiementModel> paiements,
) {
final maintenant =
DateTime.now();

double recetteJour = 0;
double recetteMois = 0;
double recetteAnnee = 0;
double resteEncaisser = 0;

int impayes = 0;
int partiels = 0;
int payes = 0;

for (final paiement
in paiements) {
if (!paiement.actif) {
continue;
}

recetteAnnee +=
paiement.montantPaye;

resteEncaisser +=
paiement.resteAPayer;

if (paiement.statut ==
"Payé") {
payes++;
}

if (paiement.statut ==
"Partiel") {
partiels++;
}

if (paiement.statut ==
"Impayé") {
impayes++;
}

if (paiement
.datePaiement.year ==
maintenant.year &&
paiement
.datePaiement.month ==
maintenant.month) {
recetteMois +=
paiement.montantPaye;
}

if (paiement
.datePaiement.year ==
maintenant.year &&
paiement
.datePaiement.month ==
maintenant.month &&
paiement
.datePaiement.day ==
maintenant.day) {
recetteJour +=
paiement.montantPaye;
}
}

return Scaffold(
backgroundColor:
const Color(
0xffF5F7FA),

appBar: AppBar(
title: const Text(
"Dashboard Financier",
),
),

body: RefreshIndicator(
onRefresh: () async {
await ref
.read(
paiementProvider
.notifier,
)
.rafraichir();
},

child: ListView(
padding:
const EdgeInsets.all(
20),

children: [

Row(
children: [

Expanded(
child:
_StatCard(
titre:
"Aujourd'hui",
valeur:
"${recetteJour.toStringAsFixed(0)} FCFA",
icone: Icons
.today,
couleur:
Colors.green,
),
),

const SizedBox(
width: 14),

Expanded(
child:
_StatCard(
titre:
"Ce mois",
valeur:
"${recetteMois.toStringAsFixed(0)} FCFA",
icone: Icons
.calendar_month,
couleur:
Colors.blue,
),
),

],
),

const SizedBox(
height: 14),

Row(
children: [

Expanded(
child:
_StatCard(
titre:
"Cette année",
valeur:
"${recetteAnnee.toStringAsFixed(0)} FCFA",
icone: Icons
.trending_up,
couleur:
Colors.deepPurple,
),
),

const SizedBox(
width: 14),

Expanded(
child:
_StatCard(
titre:
"Créances",
valeur:
"${resteEncaisser.toStringAsFixed(0)} FCFA",
icone: Icons
.payments,
couleur:
Colors.orange,
),
),

],
),

const SizedBox(
height: 20),
Row(
children: [

Expanded(
child: _StatCard(
titre: "Paiements",
valeur: payes.toString(),
icone: Icons.check_circle,
couleur: Colors.green,
),
),

const SizedBox(width: 14),

Expanded(
child: _StatCard(
titre: "Partiels",
valeur: partiels.toString(),
icone: Icons.timelapse,
couleur: Colors.orange,
),
),

const SizedBox(width: 14),

Expanded(
child: _StatCard(
titre: "Impayés",
valeur: impayes.toString(),
icone: Icons.warning,
couleur: Colors.red,
),
),

],
),

const SizedBox(height: 28),

const Text(
"Derniers paiements",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 14),

if (paiements.isEmpty)

const Card(
child: Padding(
padding: EdgeInsets.all(30),
child: Center(
child: Text(
"Aucun paiement enregistré.",
),
),
),
)

else

...paiements.take(10).map(
(paiement) {

Color couleur;

switch (paiement.statut) {
case "Payé":
couleur = Colors.green;
break;

case "Partiel":
couleur = Colors.orange;
break;

default:
couleur = Colors.red;
}

return Card(
margin:
const EdgeInsets.only(
bottom: 12,
),
child: ListTile(
leading: CircleAvatar(
backgroundColor:
couleur.withValues(
alpha: 0.15,
),
child: Icon(
Icons.payments,
color: couleur,
),
),

title: Text(
paiement.clientNom,
),

subtitle: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [

Text(
paiement.numeroFacture,
),

Text(
"${paiement.montantPaye.toStringAsFixed(0)} FCFA",
),

],
),

trailing: Chip(
backgroundColor:
couleur.withValues(
alpha: 0.15,
),
label: Text(
paiement.statut,
style: TextStyle(
color: couleur,
fontWeight:
FontWeight.bold,
),
),
),
),
);
},
),

const SizedBox(height: 30),
],
),
),
);
},
);
}
}

class _StatCard extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icone;
  final Color couleur;

  const _StatCard({
    required this.titre,
    required this.valeur,
    required this.icone,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            CircleAvatar(
              radius: 24,
              backgroundColor:
              couleur.withValues(
                alpha: 0.15,
              ),
              child: Icon(
                icone,
                color: couleur,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              valeur,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              titre,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),

          ],
        ),
      ),
    );
  }
}