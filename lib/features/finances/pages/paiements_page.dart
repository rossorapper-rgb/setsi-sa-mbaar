import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/paiement_model.dart';
import '../providers/paiement_provider.dart';
import 'add_paiement_page.dart';
import 'paiement_details_page.dart';

class PaiementsPage extends ConsumerWidget {
const PaiementsPage({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
final paiementsAsync =
ref.watch(paiementProvider);

return paiementsAsync.when(
loading: () => const Scaffold(
body: Center(
child: CircularProgressIndicator(),
),
),

error: (error, stackTrace) => Scaffold(
appBar: AppBar(
leading: IconButton(
icon: const Icon(Icons.arrow_back),
onPressed: () {
context.go('/dashboard/admin');
},
),
title: const Text(
"Gestion des paiements",
),
),
body: Center(
child: Padding(
padding:
const EdgeInsets.all(24),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
const Icon(
Icons.error_outline,
size: 70,
color: Colors.red,
),

const SizedBox(height: 20),

Text(
error.toString(),
textAlign:
TextAlign.center,
),

const SizedBox(height: 20),

ElevatedButton.icon(
onPressed: () {
ref
.read(
paiementProvider
.notifier,
)
.rafraichir();
},
icon:
const Icon(Icons.refresh),
label: const Text(
"Réessayer",
),
),
],
),
),
),
),

data: (
List<PaiementModel> paiements,
) {
final payes = paiements
.where(
(p) =>
p.statut == "Payé",
)
.length;

final partiels = paiements
.where(
(p) =>
p.statut ==
"Partiel",
)
.length;

final impayes = paiements
.where(
(p) =>
p.statut ==
"Impayé",
)
.length;

return Scaffold(
backgroundColor:
const Color(0xFFF5F7FA),

appBar: AppBar(
leading: IconButton(
icon: const Icon(
Icons.arrow_back,
),
onPressed: () {
context.go(
'/dashboard/admin');
},
),
title: const Text(
"Gestion des paiements",
),
),

floatingActionButton:
FloatingActionButton.extended(
onPressed: () async {
final resultat =
await Navigator.push<bool>(
context,
MaterialPageRoute(
builder: (_) =>
const AddPaiementPage(),
),
);

if (resultat == true &&
context.mounted) {
ref
.read(
paiementProvider
.notifier,
)
.rafraichir();
}
},
icon: const Icon(Icons.add),
label:
const Text("Paiement"),
),

body: SafeArea(
child: RefreshIndicator(
onRefresh: () async {
await ref
.read(
paiementProvider
.notifier,
)
.rafraichir();
},

child: Padding(
padding:
const EdgeInsets.all(
24),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,

children: [

Card(
child: Padding(
padding:
const EdgeInsets.all(
20),
child: Row(
children: [

Expanded(
child: _StatCard(
titre:
"Payés",
valeur: payes
.toString(),
couleur:
Colors.green,
icone: Icons
.check_circle,
),
),

const SizedBox(
width: 12),

Expanded(
child: _StatCard(
titre:
"Partiels",
valeur: partiels
.toString(),
couleur:
Colors.orange,
icone: Icons
.payments,
),
),

const SizedBox(
width: 12),

Expanded(
child: _StatCard(
titre:
"Impayés",
valeur: impayes
.toString(),
couleur:
Colors.red,
icone: Icons
.warning,
),
),

],
),
),
),

const SizedBox(
height: 24),

Expanded(
child: paiements
.isEmpty
? const Center(
child: Text(
"Aucun paiement enregistré.",
),
)
: ListView.builder(
itemCount:
paiements
.length,

itemBuilder:
(
context,
index,
) {
final paiement =
paiements[
index];

return Card(
margin:
const EdgeInsets.only(
bottom:
14,
),

child:
ListTile(

onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
PaiementDetailsPage(
paiement:
paiement,
),
),
);
},

leading:
CircleAvatar(
child:
Text(
paiement
.numeroFacture
.substring(
paiement
.numeroFacture
.length -
2,
),
),
),

title: Text(
paiement
.clientNom,
),

subtitle:
Text(
"${paiement.numeroFacture}\n"
"${paiement.montantPaye.toStringAsFixed(0)} FCFA",
),

isThreeLine:
true,

trailing:
Row(
mainAxisSize:
MainAxisSize
.min,
children: [

Chip(
label:
Text(
paiement
.statut,
),
),

PopupMenuButton<
String>(
onSelected:
(
value,
) async {
  switch (
  value) {
    case 'details':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PaiementDetailsPage(
                paiement:
                paiement,
              ),
        ),
      );
      break;

    case 'edit':
      final resultat =
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AddPaiementPage(
                isEdition:
                true,
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
      break;

    case 'delete':
      final confirmer =
      await showDialog<bool>(
        context:
        context,
        builder:
            (
            dialogContext,
            ) =>
            AlertDialog(
              title:
              const Text(
                "Confirmation",
              ),
              content:
              Text(
                "Annuler le paiement ${paiement.numeroFacture} ?",
              ),
              actions: [
                TextButton(
                  onPressed:
                      () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child:
                  const Text(
                    "Non",
                  ),
                ),
                FilledButton(
                  onPressed:
                      () {
                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  child:
                  const Text(
                    "Oui",
                  ),
                ),
              ],
            ),
      );

      if (confirmer ==
          true) {
        await ref
            .read(
          paiementProvider
              .notifier,
        )
            .annulerPaiement(
          paiement
              .id,
        );

        await ref
            .read(
          paiementProvider
              .notifier,
        )
            .rafraichir();
      }

      break;
  }
},

  itemBuilder:
      (
      context,
      ) =>
  const [

    PopupMenuItem(
      value:
      "details",
      child:
      ListTile(
        leading:
        Icon(
          Icons
              .visibility,
        ),
        title:
        Text(
          "Voir",
        ),
      ),
    ),

    PopupMenuItem(
      value:
      "edit",
      child:
      ListTile(
        leading:
        Icon(
          Icons
              .edit,
        ),
        title:
        Text(
          "Modifier",
        ),
      ),
    ),

    PopupMenuItem(
      value:
      "delete",
      child:
      ListTile(
        leading:
        Icon(
          Icons
              .cancel,
        ),
        title:
        Text(
          "Annuler",
        ),
      ),
    ),
  ],
),
],
),
),
);
},
),
),
],
),
),
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
  final Color couleur;
  final IconData icone;

  const _StatCard({
    required this.titre,
    required this.valeur,
    required this.couleur,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: couleur.withValues(
                alpha: 0.15,
              ),
              child: Icon(
                icone,
                color: couleur,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valeur,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    titre,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}