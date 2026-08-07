import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/paiement_model.dart';
import '../providers/paiement_provider.dart';

class RapportsFinanciersPage extends ConsumerWidget {
const RapportsFinanciersPage({
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
"Rapports financiers",
),
),
body: Center(
child: Text(e.toString()),
),
),
data: (
List<PaiementModel> paiements,
) {
final now = DateTime.now();

double jour = 0;
double mois = 0;
double annee = 0;

for (final p in paiements) {
if (!p.actif) continue;

if (p.datePaiement.year ==
now.year &&
p.datePaiement.month ==
now.month &&
p.datePaiement.day ==
now.day) {
jour += p.montantPaye;
}

if (p.datePaiement.year ==
now.year &&
p.datePaiement.month ==
now.month) {
mois += p.montantPaye;
}

if (p.datePaiement.year ==
now.year) {
annee += p.montantPaye;
}
}

return Scaffold(
appBar: AppBar(
title: const Text(
"Rapports financiers",
),
),

body: ListView(
padding:
const EdgeInsets.all(
16),

children: [

_rapportCard(
"Recettes du jour",
jour,
Colors.green,
Icons.today,
),

const SizedBox(height: 12),

_rapportCard(
"Recettes du mois",
mois,
Colors.blue,
Icons.calendar_month,
),

const SizedBox(height: 12),

_rapportCard(
"Recettes de l'année",
annee,
Colors.deepPurple,
Icons.trending_up,
),

const SizedBox(height: 25),
const Text(
"Exports",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 12),

Card(
child: ListTile(
leading: const Icon(
Icons.picture_as_pdf,
color: Colors.red,
),
title: const Text(
"Exporter en PDF",
),
subtitle: const Text(
"Rapport financier",
),
trailing: const Icon(
Icons.chevron_right,
),
onTap: () {
ScaffoldMessenger.of(
context,
).showSnackBar(
const SnackBar(
content: Text(
"Fonction disponible prochainement",
),
),
);
},
),
),

const SizedBox(height: 10),

Card(
child: ListTile(
leading: const Icon(
Icons.table_chart,
color: Colors.green,
),
title: const Text(
"Exporter en Excel",
),
subtitle: const Text(
"Rapport financier",
),
trailing: const Icon(
Icons.chevron_right,
),
onTap: () {
ScaffoldMessenger.of(
context,
).showSnackBar(
const SnackBar(
content: Text(
"Fonction disponible prochainement",
),
),
);
},
),
),

const SizedBox(height: 25),

const Text(
"Résumé",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 12),

Card(
child: Padding(
padding:
const EdgeInsets.all(
16),
child: Column(
children: [

_resumeRow(
"Nombre de paiements",
paiements.length
.toString(),
),

const Divider(),

_resumeRow(
"Paiements actifs",
paiements
.where(
(e) =>
e.actif,
)
.length
.toString(),
),

const Divider(),

_resumeRow(
"Montant encaissé",
"${annee.toStringAsFixed(0)} FCFA",
),

],
),
),
),

const SizedBox(height: 30),
],
),
);
},
);
}

Widget _rapportCard(
    String titre,
    double montant,
    Color couleur,
    IconData icone,
    ) {
  return Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor:
        couleur.withValues(
          alpha: 0.15,
        ),
        child: Icon(
          icone,
          color: couleur,
        ),
      ),
      title: Text(titre),
      subtitle: Text(
        "${montant.toStringAsFixed(0)} FCFA",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ),
  );
}

Widget _resumeRow(
    String titre,
    String valeur,
    ) {
  return Row(
    children: [

      Expanded(
        child: Text(
          titre,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      Text(
        valeur,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

    ],
  );
}
}
