import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/paiement_model.dart';
import '../providers/paiement_provider.dart';
import 'add_paiement_page.dart';

enum FiltreCreance {
  tous,
  impayes,
  partiels,
}

class CreancesPage extends ConsumerStatefulWidget {
  const CreancesPage({
    super.key,
  });

  @override
  ConsumerState<CreancesPage> createState() =>
      _CreancesPageState();
}

class _CreancesPageState
    extends ConsumerState<CreancesPage> {
FiltreCreance _filtre =
FiltreCreance.tous;

@override
Widget build(BuildContext context) {
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
title:
const Text("Créances"),
),
body: Center(
child: Text(
e.toString(),
),
),
),
data: (
List<PaiementModel> paiements,
) {
List<PaiementModel> creances =
paiements
.where(
(p) =>
p.resteAPayer > 0 &&
p.actif,
)
.toList();

switch (_filtre) {
case FiltreCreance.impayes:
creances = creances
.where(
(p) =>
p.statut ==
"Impayé",
)
.toList();
break;

case FiltreCreance.partiels:
creances = creances
.where(
(p) =>
p.statut ==
"Partiel",
)
.toList();
break;

case FiltreCreance.tous:
break;
}

double totalCreances = 0;

for (final paiement
in creances) {
totalCreances +=
paiement.resteAPayer;
}

return Scaffold(
appBar: AppBar(
title:
const Text("Créances"),
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
16),
children: [

Card(
child: Padding(
padding:
const EdgeInsets.all(
20),
child: Column(
children: [

const Icon(
Icons.payments,
size: 42,
color:
Colors.red,
),

const SizedBox(
height: 10),

Text(
"${totalCreances.toStringAsFixed(0)} FCFA",
style:
const TextStyle(
fontSize: 28,
fontWeight:
FontWeight
.bold,
),
),

const SizedBox(
height: 6),

Text(
"${creances.length} créance(s)",
),

],
),
),
),

const SizedBox(
height: 20),

SegmentedButton<
FiltreCreance>(
segments: const [

ButtonSegment(
value:
FiltreCreance
.tous,
label: Text(
"Tous"),
),

ButtonSegment(
value:
FiltreCreance
.impayes,
label: Text(
"Impayés"),
),

ButtonSegment(
value:
FiltreCreance
.partiels,
label: Text(
"Partiels"),
),

],

selected: {
_filtre,
},

onSelectionChanged:
(value) {
setState(() {
_filtre =
value.first;
});
},
),

const SizedBox(
height: 20),
if (creances.isEmpty)

const Card(
child: Padding(
padding: EdgeInsets.all(30),
child: Center(
child: Text(
"Aucune créance.",
),
),
),
)

else

...creances.map(
(paiement) {

return Card(
margin:
const EdgeInsets.only(
bottom: 14,
),

child: Padding(
padding:
const EdgeInsets.all(
16),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,

children: [

Row(
children: [

const CircleAvatar(
child: Icon(
Icons.person,
),
),

const SizedBox(
width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [

Text(
paiement.clientNom,
style:
const TextStyle(
fontWeight:
FontWeight.bold,
fontSize:
17,
),
),

Text(
paiement.bergerieNom,
),

],
),
),

Chip(
backgroundColor:
Colors.red
.withValues(
alpha: 0.15,
),
label: Text(
"${paiement.resteAPayer.toStringAsFixed(0)} FCFA",
style:
const TextStyle(
color:
Colors.red,
fontWeight:
FontWeight.bold,
),
),
),

],
),

const SizedBox(
height: 18),

Row(
children: [

Expanded(
child:
_montantCard(
"Facturé",
paiement
.montantFacture,
Colors.blue,
),
),

const SizedBox(
width: 10),

Expanded(
child:
_montantCard(
"Payé",
paiement
.montantPaye,
Colors.green,
),
),

const SizedBox(
width: 10),

Expanded(
child:
_montantCard(
"Reste",
paiement
.resteAPayer,
Colors.red,
),
),

],
),

const SizedBox(
height: 18),

SizedBox(
width:
double.infinity,

child:
ElevatedButton.icon(
icon:
const Icon(
Icons
.payments,
),

label:
const Text(
"Encaisser le solde",
),

onPressed:
() async {
final resultat =
await Navigator.push<bool>(
context,
MaterialPageRoute(
builder: (_) =>
AddPaiementPage(
paiement:
paiement,
),
),
);

if (resultat ==
true) {
await ref
.read(
paiementProvider
.notifier,
)
.rafraichir();
}
},
),
),

],
),
),
);
},
),

const SizedBox(
height: 30),
],
),
),
);
},
);
}

Widget _montantCard(
    String titre,
    double montant,
    Color couleur,
    ) {
  return Card(
    elevation: 0,
    color: couleur.withValues(
      alpha: 0.08,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      child: Column(
        children: [
          Text(
            titre,
            style: TextStyle(
              color: couleur,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${montant.toStringAsFixed(0)} FCFA",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: couleur,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}
}