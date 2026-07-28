import 'package:flutter/material.dart';

import '../../bergeries/models/bergerie_model.dart';
import '../../bergeries/repository/firebase_bergerie_repository.dart';
import '../../clients/models/client_model.dart';
import '../../clients/repositories/firebase_client_repository.dart';import '../models/mouton_model.dart';
import '../widgets/mouton_header.dart';
import '../widgets/mouton_reproduction_tab.dart';

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
final FirebaseBergerieRepository _bergerieRepository =
FirebaseBergerieRepository();

final FirebaseClientRepository _clientRepository =
FirebaseClientRepository();

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
final bergerie =
await _bergerieRepository.getBergerieById(
widget.mouton.bergerieId,
);

if (bergerie == null) {
setState(() {
_loading = false;
_error = "Bergerie introuvable.";
});
return;
}

final client =
await _clientRepository.getClientById(
bergerie.clientId,
);

if (client == null) {
setState(() {
_loading = false;
_error = "Client introuvable.";
});
return;
}

setState(() {
_bergerie = bergerie;
_client = client;
_loading = false;
});
} catch (e) {
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

int annees = now.year - naissance.year;

if (now.month < naissance.month ||
(now.month == naissance.month &&
now.day < naissance.day)) {
annees--;
}

if (annees < 1) {
final mois =
(now.year - naissance.year) * 12 +
now.month -
naissance.month;

return "$mois mois";
}

return "$annees an(s)";
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
color: Colors.green,
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
return Card(
elevation: 0,
margin: const EdgeInsets.only(bottom: 10),
child: ListTile(
leading: Icon(
icon,
color: Colors.green,
),
title: Text(titre),
subtitle: Text(
valeur,
style: const TextStyle(
fontWeight: FontWeight.w600,
),
),
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
),
icon: Icon(icon),
label: Text(texte),
onPressed: onPressed,
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
return Scaffold(
appBar: AppBar(
title: const Text("Fiche du mouton"),
),
body: Center(
child: Padding(
padding: const EdgeInsets.all(20),
child: Text(
_error!,
style: const TextStyle(
color: Colors.red,
fontSize: 16,
),
textAlign: TextAlign.center,
),
),
),
);
}

final bergerie = _bergerie!;
final client = _client!;

return Scaffold(
appBar: AppBar(
title: const Text("Fiche du mouton"),
centerTitle: true,
),
body: ListView(
padding: const EdgeInsets.all(16),
children: [
const SizedBox(height: 10),

  MoutonHeader(
    mouton: widget.mouton,
  ),

  const SizedBox(height: 20),

_sectionTitle(
Icons.info_outline,
"Informations générales",
),

_infoTile(
icon: Icons.qr_code,
titre: "Identification",
valeur: widget.mouton.numeroIdentification,
),

_infoTile(
icon: Icons.pets,
titre: "Race",
valeur: widget.mouton.race,
),

_infoTile(
icon: widget.mouton.sexe == "Mâle"
? Icons.male
: Icons.female,
titre: "Sexe",
valeur: widget.mouton.sexe,
),

_infoTile(
icon: Icons.monitor_weight,
titre: "Poids",
valeur:
"${widget.mouton.poids.toStringAsFixed(1)} kg",
),

_infoTile(
icon: Icons.palette,
titre: "Couleur",
valeur: widget.mouton.couleur,
),

_infoTile(
icon: Icons.cake,
titre: "Date de naissance",
valeur: _formatDate(
widget.mouton.dateNaissance,
),
),

_infoTile(
icon: Icons.schedule,
titre: "Âge",
valeur: _calculAge(
widget.mouton.dateNaissance,
),
),

_sectionTitle(
Icons.person,
"Propriétaire et bergerie",
),

_infoTile(
icon: Icons.person,
titre: "Client",
valeur: client.nom,
),

_infoTile(
icon: Icons.phone,
titre: "Téléphone",
valeur: client.telephone,
),

_infoTile(
icon: Icons.location_city,
titre: "Quartier",
valeur: client.quartier,
),

_infoTile(
icon: Icons.home_work,
titre: "Bergerie",
valeur: bergerie.nom,
),

_infoTile(
icon: Icons.location_on,
titre: "Adresse",
valeur: bergerie.adresse,
),

_infoTile(
icon: Icons.supervisor_account,
titre: "Responsable",
valeur: bergerie.responsable,
),

_sectionTitle(
Icons.notes,
"Observations",
),

Card(
elevation: 0,
child: Padding(
padding: const EdgeInsets.all(16),
child: Text(
bergerie.observations.trim().isEmpty
? "Aucune observation enregistrée."
: bergerie.observations,
style: const TextStyle(
fontSize: 15,
),
),
),
),
  const SizedBox(height: 10),

  _sectionTitle(
    Icons.favorite,
    "Reproduction",
  ),

  MoutonReproductionTab(
    mouton: widget.mouton,
  ),

_sectionTitle(
Icons.dashboard_customize,
"Actions",
),

_actionButton(
icon: Icons.edit,
texte: "Modifier le mouton",
couleur: Colors.orange,
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Page de modification bientôt disponible.",
),
),
);
},
),
  const SizedBox(height: 12),

  _actionButton(
    icon: Icons.delete,
    texte: "Supprimer le mouton",
    couleur: Colors.red,
    onPressed: () async {
      final supprimer = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Confirmation"),
          content: const Text(
            "Voulez-vous vraiment supprimer ce mouton ?",
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

      if (supprimer == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Suppression bientôt connectée à Firebase.",
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
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Module Santé bientôt disponible.",
),
),
);
},
),

const SizedBox(height: 12),
  _actionButton(
    icon: Icons.pregnant_woman,
    texte: "Gestation",
    couleur: Colors.purple,
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Module Gestation bientôt disponible.",
          ),
        ),
      );
    },
  ),

  const SizedBox(height: 12),

  _actionButton(
    icon: Icons.cleaning_services,
    texte: "Interventions",
    couleur: Colors.green,
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Module Interventions bientôt disponible.",
          ),
        ),
      );
    },
  ),

  const SizedBox(height: 30),
],
),
);
}
}
