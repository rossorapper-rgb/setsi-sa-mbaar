import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

import '../models/paiement_model.dart';
import 'add_paiement_page.dart';
import '../services/facture_pdf_service.dart';
import '../services/recu_pdf_service.dart';

class PaiementDetailsPage extends StatefulWidget {
  final PaiementModel paiement;

  const PaiementDetailsPage({
    super.key,
    required this.paiement,
  });

  @override
  State<PaiementDetailsPage> createState() =>
      _PaiementDetailsPageState();
}

class _PaiementDetailsPageState
    extends State<PaiementDetailsPage> {

Widget _sectionTitle(
IconData icon,
String titre,
) {
return Padding(
padding: const EdgeInsets.only(
top: 22,
bottom: 12,
),
child: Row(
children: [

Icon(
icon,
color: Theme.of(context)
.colorScheme
.primary,
),

const SizedBox(width: 10),

Text(
titre,
style: const TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),

],
),
);
}

Widget _infoTile({
required IconData icon,
required String titre,
required String valeur,
}) {
return Padding(
padding:
const EdgeInsets.only(
bottom: 14,
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

Icon(
icon,
color: Theme.of(context)
.colorScheme
.primary,
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [

Text(
titre,
style: TextStyle(
color:
Colors.grey.shade600,
fontSize: 13,
),
),

const SizedBox(
height: 3,
),

Text(
valeur,
style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w600,
),
),

],
),
),
],
),
);
}

Widget _actionButton({
required IconData icon,
required String texte,
required Color couleur,
required VoidCallback onPressed,
}) {
return SizedBox(
width: double.infinity,
height: 52,
child: ElevatedButton.icon(
style:
ElevatedButton.styleFrom(
backgroundColor:
couleur,
foregroundColor:
Colors.white,
),
onPressed: onPressed,
icon: Icon(icon),
label: Text(texte),
),
);
}

@override
Widget build(BuildContext context) {

final paiement =
widget.paiement;

return ResponsivePage(
title:
paiement.numeroFacture,

child: ListView(

children: [

AppCard(
child: Column(
children: [

CircleAvatar(
radius: 36,
child: Text(
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

const SizedBox(
height: 14),

Text(
paiement.clientNom,
style:
const TextStyle(
fontSize: 22,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 6),

Chip(
label: Text(
paiement.statut,
),
),

],
),
),

_sectionTitle(
Icons.person,
"Client",
),

AppCard(
child: Column(
children: [

_infoTile(
icon: Icons.person,
titre: "Nom",
valeur:
paiement.clientNom,
),

_infoTile(
icon: Icons.home,
titre: "Bergerie",
valeur:
paiement.bergerieNom,
),

_infoTile(
icon: Icons.receipt,
titre:
"Facture",
valeur: paiement
.numeroFacture,
),

],
),
),
_sectionTitle(
Icons.payments,
"Paiement",
),

AppCard(
child: Column(
children: [

_infoTile(
icon: Icons.category,
titre: "Prestation",
valeur: paiement.typePrestation.name,
),

_infoTile(
icon: Icons.price_change,
titre: "Montant conseillé",
valeur:
"${paiement.montantConseille.toStringAsFixed(0)} FCFA",
),

_infoTile(
icon: Icons.receipt_long,
titre: "Montant facturé",
valeur:
"${paiement.montantFacture.toStringAsFixed(0)} FCFA",
),

_infoTile(
icon: Icons.payments,
titre: "Montant payé",
valeur:
"${paiement.montantPaye.toStringAsFixed(0)} FCFA",
),

_infoTile(
icon: Icons.account_balance_wallet,
titre: "Reste à payer",
valeur:
"${paiement.resteAPayer.toStringAsFixed(0)} FCFA",
),

_infoTile(
icon: Icons.credit_card,
titre: "Mode de paiement",
valeur: paiement.modePaiement.name,
),

_infoTile(
icon: Icons.tag,
titre: "Référence",
valeur: paiement.reference.isEmpty
? "-"
: paiement.reference,
),

],
),
),

_sectionTitle(
Icons.notes,
"Observations",
),

AppCard(
child: Text(
paiement.observations.trim().isEmpty
? "Aucune observation."
: paiement.observations,
style: const TextStyle(
fontSize: 15,
),
),
),

const SizedBox(height: 24),

_sectionTitle(
Icons.settings,
"Actions",
),

AppCard(
child: Column(
children: [

_actionButton(
icon: Icons.edit,
texte: "Modifier le paiement",
couleur: Colors.orange,
onPressed: () async {

final resultat =
await Navigator.push<bool>(
context,
MaterialPageRoute(
builder: (_) =>
AddPaiementPage(
isEdition: true,
paiement: paiement,
),
),
);

if (!mounted) return;

if (resultat == true) {
Navigator.pop(
context,
true,
);
}
},
),

  const SizedBox(height: 12),

  _actionButton(
    icon: Icons.picture_as_pdf,
    texte: "Générer la facture PDF",
    couleur: Colors.blue,
    onPressed: () async {
      final fichier =
      await FacturePdfService
          .genererFacture(
        paiement,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Facture enregistrée : ${fichier.path}",
          ),
        ),
      );
    },
  ),

  const SizedBox(height: 12),

  _actionButton(
    icon: Icons.receipt_long,
    texte: "Générer le reçu PDF",
    couleur: Colors.green,
    onPressed: () async {
      final fichier =
      await RecuPdfService
          .genererRecu(
        paiement,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Reçu enregistré : ${fichier.path}",
          ),
        ),
      );
    },
  ),

  const SizedBox(height: 12),
_actionButton(
icon: Icons.cancel,
texte: "Annuler le paiement",
couleur: Colors.red,
onPressed: () async {

final confirmer =
await showDialog<bool>(
context: context,
builder: (_) =>
AlertDialog(
title: const Text(
"Confirmation",
),
content: Text(
"Annuler la facture ${paiement.numeroFacture} ?",
),
actions: [

TextButton(
onPressed: () =>
Navigator.pop(
context,
false,
),
child: const Text(
"Non",
),
),

FilledButton(
onPressed: () =>
Navigator.pop(
context,
true,
),
child: const Text(
"Oui",
),
),

],
),
);

if (confirmer != true) {
return;
}
ScaffoldMessenger.of(context)
    .showSnackBar(
  const SnackBar(
    content: Text(
      "L'annulation du paiement sera disponible dans la prochaine étape.",
    ),
  ),
);
},
),
],
),
),

  const SizedBox(height: 30),
],
),
);
}
}