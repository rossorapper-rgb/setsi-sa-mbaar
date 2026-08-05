import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

import '../../bergeries/models/bergerie_model.dart';
import '../../bergeries/repository/firebase_bergerie_repository.dart';
import '../../clients/models/client_model.dart';
import '../../clients/repositories/firebase_client_repository.dart';

import '../models/mouton_model.dart';
import '../widgets/mouton_header.dart';
import '../widgets/mouton_reproduction_tab.dart';
import 'add_mouton_page.dart';
import '../repository/firebase_mouton_repository.dart';

class MoutonDetailsPage extends StatefulWidget {
  final MoutonModel mouton;

  const MoutonDetailsPage({
    super.key,
    required this.mouton,
  });

  @override
  State<MoutonDetailsPage> createState() =>
      _MoutonDetailsPageState();
}

class _MoutonDetailsPageState
    extends State<MoutonDetailsPage> {

final FirebaseBergerieRepository
_bergerieRepository =
FirebaseBergerieRepository();

final FirebaseClientRepository
_clientRepository =
FirebaseClientRepository();
final FirebaseMoutonRepository
_moutonRepository =
FirebaseMoutonRepository();

BergerieModel? _bergerie;
ClientModel? _client;

bool _loading = true;
String? _error;

@override
void initState() {
super.initState();
_chargerDonnees();
}

Future<void> _chargerDonnees() async {
  try {
    debugPrint("========== DIAGNOSTIC ==========");
    debugPrint("Mouton id        : '${widget.mouton.id}'");
    debugPrint("Bergerie id      : '${widget.mouton.bergerieId}'");

    if (widget.mouton.bergerieId.trim().isEmpty) {
      throw Exception("bergerieId est vide");
    }

    final bergerie = await _bergerieRepository.getBergerieById(
      widget.mouton.bergerieId,
    );

    debugPrint("Bergerie trouvée : ${bergerie?.nom}");

    if (bergerie == null) {
      throw Exception("Bergerie introuvable");
    }

    debugPrint("Client id        : '${bergerie.clientId}'");

    if (bergerie.clientId.trim().isEmpty) {
      throw Exception("clientId est vide");
    }

    final client = await _clientRepository.getClientById(
      bergerie.clientId,
    );

    debugPrint("Client trouvé    : ${client?.nom}");

    setState(() {
      _bergerie = bergerie;
      _client = client;
      _loading = false;
    });
  } catch (e, s) {
    debugPrint(e.toString());
    debugPrint(s.toString());

    setState(() {
      _loading = false;
      _error = e.toString();
    });
  }
}

String _formatDate(DateTime? date) {
if (date == null) {
return "Non renseignée";
}

return "${date.day.toString().padLeft(2, '0')}/"
"${date.month.toString().padLeft(2, '0')}/"
"${date.year}";
}
String _calculAge(DateTime? naissance) {
if (naissance == null) {
return "Non renseigné";
}

final now = DateTime.now();

int mois =
(now.year - naissance.year) * 12 +
now.month -
naissance.month;

if (now.day < naissance.day) {
mois--;
}

if (mois < 12) {
return "$mois mois";
}

final ans = mois ~/ 12;
final reste = mois % 12;

if (reste == 0) {
return "$ans an${ans > 1 ? "s" : ""}";
}

return "$ans an${ans > 1 ? "s" : ""} - $reste mois";
}

Widget _sectionTitle(
IconData icon,
String titre,
) {
return Padding(
padding: const EdgeInsets.only(
top: 24,
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
fontWeight: FontWeight.bold,
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
const EdgeInsets.only(bottom: 12),
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

const SizedBox(width: 15),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
titre,
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 13,
),
),

const SizedBox(height: 3),

Text(
valeur,
style: const TextStyle(
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
style: ElevatedButton.styleFrom(
backgroundColor: couleur,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(12),
),
),
onPressed: onPressed,
icon: Icon(icon),
label: Text(texte),
),
);
}

@override
Widget build(BuildContext context) {
if (_loading) {
return const Scaffold(
body: Center(
child: CircularProgressIndicator(),
),
);
}

if (_error != null) {
return ResponsivePage(
title: "Fiche du mouton",
child: Center(
child: AppCard(
child: Padding(
padding:
const EdgeInsets.all(30),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
const Icon(
Icons.error_outline,
color: Colors.red,
size: 70,
),

const SizedBox(height: 20),

Text(
_error!,
textAlign:
TextAlign.center,
style: const TextStyle(
fontSize: 16,
),
),
],
),
),
),
),
);
}

final bergerie = _bergerie!;
final client = _client!;

return ResponsivePage(
title: widget.mouton.nom,
child: ListView(
children: [
MoutonHeader(
mouton: widget.mouton,
),

const SizedBox(height: 20),
_sectionTitle(
Icons.badge,
"Identité",
),

AppCard(
child: Column(
children: [
_infoTile(
icon: Icons.qr_code,
titre: "Identification",
valeur: widget.mouton
.numeroIdentification,
),

_infoTile(
icon: Icons.pets,
titre: "Race",
valeur: widget.mouton.race,
),

_infoTile(
icon:
widget.mouton.sexe ==
"Mâle"
? Icons.male
: Icons.female,
titre: "Sexe",
valeur: widget.mouton.sexe,
),

_infoTile(
icon:
Icons.monitor_weight,
titre: "Poids",
valeur:
"${widget.mouton.poids.toStringAsFixed(1)} kg",
),

_infoTile(
icon: Icons.palette,
titre: "Couleur",
valeur:
widget.mouton.couleur,
),

_infoTile(
icon: Icons.cake,
titre: "Naissance",
valeur: _formatDate(
widget.mouton
.dateNaissance,
),
),

_infoTile(
icon: Icons.schedule,
titre: "Âge",
valeur: _calculAge(
widget.mouton
.dateNaissance,
),
),

_infoTile(
icon:
Icons.check_circle,
titre: "Statut",
valeur:
widget.mouton.actif
? "Actif"
: "Inactif",
),
],
),
),

_sectionTitle(
Icons.person,
"Propriétaire",
),

AppCard(
child: Column(
children: [
_infoTile(
icon: Icons.person,
titre: "Nom",
valeur: client.nom,
),

_infoTile(
icon: Icons.phone,
titre: "Téléphone",
valeur:
client.telephone,
),

_infoTile(
icon:
Icons.location_city,
titre: "Quartier",
valeur:
client.quartier,
),
],
),
),

_sectionTitle(
Icons.home_work,
"Bergerie",
),
AppCard(
child: Column(
children: [
_infoTile(
icon: Icons.home,
titre: "Nom",
valeur: bergerie.nom,
),

_infoTile(
icon: Icons.location_on,
titre: "Adresse",
valeur: bergerie.adresse,
),

_infoTile(
icon:
Icons.supervisor_account,
titre: "Responsable",
valeur:
bergerie.responsable,
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
bergerie.observations
.trim()
.isEmpty
? "Aucune observation enregistrée."
: bergerie.observations,
style: const TextStyle(
fontSize: 15,
),
),
),

_sectionTitle(
Icons.favorite,
"Reproduction",
),

AppCard(
child:
MoutonReproductionTab(
mouton: widget.mouton,
),
),

const SizedBox(height: 25),

_sectionTitle(
Icons.dashboard_customize,
"Actions",
),

AppCard(
child: Column(
children: [
_actionButton(
icon: Icons.edit,
texte:
"Modifier le mouton",
couleur: Colors.orange,
  onPressed: () async {
    final resultat = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMoutonPage(
          bergerie: _bergerie!,
          mouton: widget.mouton,
        ),
      ),
    );

    if (!mounted) return;

    if (resultat == true) {
      Navigator.pop(context, true);
    }
  },
),

const SizedBox(height: 12),

_actionButton(
icon: Icons.delete,
texte:
"Supprimer le mouton",
couleur: Colors.red,
  onPressed: () async {
    final supprimer = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation"),
        content: Text(
          "Voulez-vous supprimer ${widget.mouton.nom} ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (supprimer != true) return;

    try {
      await _moutonRepository.deleteMouton(widget.mouton.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Le mouton a été supprimé avec succès.",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Erreur : $e",
          ),
        ),
      );
    }
  },
),

const SizedBox(height: 12),

_actionButton(
icon: Icons.favorite,
texte: "Santé",
couleur: Colors.red,
onPressed: () {
ScaffoldMessenger.of(
context)
.showSnackBar(
const SnackBar(
content: Text(
"Le module Santé sera bientôt disponible.",
),
),
);
},
),

const SizedBox(height: 12),
_actionButton(
icon: Icons.pregnant_woman,
texte: "Gestation",
couleur: Colors.deepPurple,
onPressed: () {
ScaffoldMessenger.of(
context)
.showSnackBar(
const SnackBar(
content: Text(
"Ouverture du module Gestation prochainement.",
),
),
);
},
),

const SizedBox(height: 12),

_actionButton(
icon:
Icons.cleaning_services,
texte: "Interventions",
couleur: Colors.green,
onPressed: () {
ScaffoldMessenger.of(
context)
.showSnackBar(
const SnackBar(
content: Text(
"Ouverture du module Interventions prochainement.",
),
),
);
},
),

const SizedBox(height: 12),

_actionButton(
icon: Icons.history,
texte: "Historique",
couleur:
Colors.blueGrey,
onPressed: () {
ScaffoldMessenger.of(
context)
.showSnackBar(
const SnackBar(
content: Text(
"L'historique complet sera disponible dans une prochaine version.",
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