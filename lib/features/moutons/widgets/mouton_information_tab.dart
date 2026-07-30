import 'package:flutter/material.dart';

import '../../bergeries/models/bergerie_model.dart';
import '../../clients/models/client_model.dart';
import '../models/mouton_model.dart';

class MoutonInformationTab extends StatelessWidget {
final MoutonModel mouton;
final BergerieModel bergerie;
final ClientModel client;

const MoutonInformationTab({
super.key,
required this.mouton,
required this.bergerie,
required this.client,
});

String _formatDate(DateTime? date) {
if (date == null) {
return "Non renseignée";
}

return "${date.day.toString().padLeft(2, '0')}/"
"${date.month.toString().padLeft(2, '0')}/"
"${date.year}";
}

String _calculAge(
DateTime? naissance,
) {
if (naissance == null) {
return "Non renseigné";
}

final now = DateTime.now();

int annees =
now.year - naissance.year;

if (now.month <
naissance.month ||
(now.month ==
naissance.month &&
now.day <
naissance.day)) {
annees--;
}

if (annees < 1) {
final mois =
(now.year -
naissance.year) *
12 +
now.month -
naissance.month;

return "$mois mois";
}

return "$annees an(s)";
}

@override
Widget build(
BuildContext context,
) {
return ListView(
padding:
const EdgeInsets.all(16),
children: [
_sectionTitle(
Icons.info_outline,
"Informations générales",
),

_infoTile(
icon: Icons.qr_code,
titre: "Identification",
valeur: mouton
.numeroIdentification,
),

_infoTile(
icon: Icons.pets,
titre: "Race",
valeur: mouton.race,
),

_infoTile(
icon: mouton.sexe ==
"Mâle"
? Icons.male
: Icons.female,
titre: "Sexe",
valeur: mouton.sexe,
),
_infoTile(
icon: Icons.monitor_weight,
titre: "Poids",
valeur:
"${mouton.poids.toStringAsFixed(1)} kg",
),

_infoTile(
icon: Icons.palette,
titre: "Couleur",
valeur: mouton.couleur,
),

_infoTile(
icon: Icons.cake,
titre: "Date de naissance",
valeur: _formatDate(
mouton.dateNaissance,
),
),

_infoTile(
icon: Icons.schedule,
titre: "Âge",
valeur: _calculAge(
mouton.dateNaissance,
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
icon:
Icons.supervisor_account,
titre: "Responsable",
valeur:
bergerie.responsable,
),

_sectionTitle(
Icons.notes,
"Observations",
),

Card(
elevation: 0,
child: Padding(
padding:
const EdgeInsets.all(16),
child: Text(
bergerie.observations
.trim()
.isEmpty
? "Aucune observation enregistrée."
: bergerie
.observations,
),
),
),

const SizedBox(
height: 20,
),
],
);
}

Widget _sectionTitle(
IconData icon,
String titre,
) {
return Padding(
padding:
const EdgeInsets.only(
top: 20,
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
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(
      bottom: 10,
    ),
    child: ListTile(
      leading: Icon(
        icon,
        color: Colors.green,
      ),
      title: Text(titre),
      subtitle: Text(
        valeur,
        style: const TextStyle(
          fontWeight:
          FontWeight.w600,
        ),
      ),
    ),
  );
}
}