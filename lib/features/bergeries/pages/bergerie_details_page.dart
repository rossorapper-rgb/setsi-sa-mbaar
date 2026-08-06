import 'package:flutter/material.dart';

import '../../../core/widgets/app_back_bar.dart';

import '../../clients/models/client_model.dart';
import '../../clients/repositories/firebase_client_repository.dart';
import '../../moutons/pages/moutons_page.dart';

import 'add_bergerie_page.dart';

import '../models/bergerie_model.dart';
import '../../interventions/pages/interventions_page.dart';
import '../../gestation/pages/gestations_page.dart';
class BergerieDetailsPage extends StatefulWidget {
  final BergerieModel bergerie;

  const BergerieDetailsPage({
    super.key,
    required this.bergerie,
  });

  @override
  State<BergerieDetailsPage> createState() =>
      _BergerieDetailsPageState();
}

class _BergerieDetailsPageState
    extends State<BergerieDetailsPage> {
final FirebaseClientRepository _clientRepository =
FirebaseClientRepository();

ClientModel? _client;

@override
void initState() {
super.initState();
_chargerClient();
}

Future<void> _chargerClient() async {
final client = await _clientRepository.getClientById(
widget.bergerie.clientId,
);

if (!mounted) return;

setState(() {
_client = client;
});
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBackBar(
title: "Détails de la bergerie",
actions: [
IconButton(
icon: const Icon(Icons.edit),
tooltip: "Modifier",
onPressed: () async {
final result = await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => AddBergeriePage(
isEdition: true,
bergerie: widget.bergerie,
),
),
);

if (result == true && mounted) {
Navigator.pop(context, true);
}
},
),
],
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
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
widget.bergerie.nom,
style: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

ListTile(
contentPadding: EdgeInsets.zero,
leading: const Icon(Icons.person),
title: const Text("Client"),
subtitle: Text(
_client?.nom ?? "Chargement...",
),
),

ListTile(
contentPadding: EdgeInsets.zero,
leading: const Icon(Icons.badge),
title: const Text("Responsable"),
subtitle: Text(
widget.bergerie.responsable.isEmpty
? "-"
: widget.bergerie.responsable,
),
),

ListTile(
contentPadding: EdgeInsets.zero,
leading: const Icon(Icons.phone),
title: const Text("Téléphone"),
subtitle: Text(
_client?.telephone ??
widget.bergerie.telephone,
),
),

ListTile(
contentPadding: EdgeInsets.zero,
leading: const Icon(Icons.location_on),
title: const Text("Adresse"),
subtitle: Text(
widget.bergerie.adresse.isEmpty
? "-"
: widget.bergerie.adresse,
),
),
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
            bergerie: widget.bergerie,
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
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const InterventionsPage(),
        ),
      );
    },
  ),

  _menuCard(
    context,
    icon: Icons.calendar_month,
    title: "Gestations",
    subtitle: "Suivi des gestations",
    onTap: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GestationsPage(
            bergerie: widget.bergerie,
          ),
        ),
      );
    },
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
                content: Text(
                  "$title disponible prochainement",
                ),
              ),
            );
          },
    ),
  );
}
}