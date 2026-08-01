import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../moutons/repository/firebase_mouton_repository.dart';
import '../models/bergerie_model.dart';
import '../repository/firebase_bergerie_repository.dart';
import 'add_bergerie_page.dart';
import 'bergerie_details_page.dart';
import 'package:go_router/go_router.dart';
class BergeriesPage extends StatefulWidget {
  const BergeriesPage({super.key});

  @override
  State<BergeriesPage> createState() => _BergeriesPageState();
}

class _BergeriesPageState extends State<BergeriesPage> {
final FirebaseBergerieRepository _repository =
FirebaseBergerieRepository();

final FirebaseMoutonRepository _moutonRepository =
FirebaseMoutonRepository();

late Future<List<BergerieModel>> _futureBergeries;

@override
void initState() {
super.initState();
_loadBergeries();
}

void _loadBergeries() {
_futureBergeries = _repository.getAllBergeries();
}

Future<void> _ouvrirAjout() async {
final result = await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const AddBergeriePage(),
),
);

if (!mounted) return;

if (result == true) {
setState(() {
_loadBergeries();
});
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
  appBar: AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        context.go('/dashboard/admin');
      },
    ),
    title: const Text("Mes bergeries"),
    centerTitle: true,
  ),
floatingActionButton: FloatingActionButton.extended(
onPressed: _ouvrirAjout,
icon: const Icon(Icons.add),
label: const Text("Nouvelle"),
),
body: FutureBuilder<List<BergerieModel>>(
future: _futureBergeries,
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: Text(
"Erreur : ${snapshot.error}",
),
);
}

final bergeries = snapshot.data ?? [];

if (bergeries.isEmpty) {
return const Center(
child: Text(
"Aucune bergerie enregistrée.",
style: TextStyle(fontSize: 16),
),
);
}

return ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: bergeries.length,
itemBuilder: (context, index) {
final bergerie = bergeries[index];

return Card(
elevation: 3,
margin: const EdgeInsets.only(bottom: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(18),
),
child: Padding(
padding: const EdgeInsets.all(18),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
CircleAvatar(
radius: 28,
backgroundColor:
Colors.green.shade100,
child: Icon(
Icons.home_work,
color:
Colors.green.shade800,
size: 28,
),
),
const SizedBox(width: 15),
Expanded(
child: Text(
bergerie.nom.toUpperCase(),
style: const TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),
),
Chip(
avatar: Icon(
Icons.check_circle,
color:
Colors.green.shade800,
size: 18,
),
label: const Text("Active"),
backgroundColor:
Colors.green.shade50,
),
],
),

const Divider(height: 30),
ListTile(
dense: true,
contentPadding: EdgeInsets.zero,
leading: const Icon(Icons.person),
title: const Text("Responsable"),
subtitle: Text(
bergerie.responsable.isEmpty
? "-"
: bergerie.responsable,
),
),

ListTile(
dense: true,
contentPadding: EdgeInsets.zero,
leading: const Icon(Icons.phone),
title: const Text("Téléphone"),
subtitle: Text(
bergerie.telephone,
),
),

ListTile(
dense: true,
contentPadding: EdgeInsets.zero,
leading: const Icon(Icons.location_on),
title: const Text("Adresse"),
subtitle: Text(
bergerie.adresse.isEmpty
? "-"
: bergerie.adresse,
),
),

ListTile(
dense: true,
contentPadding: EdgeInsets.zero,
leading: const Icon(Icons.calendar_today),
title: const Text("Créée le"),
subtitle: Text(
DateFormat(
"dd/MM/yyyy",
"fr_FR",
).format(
bergerie.dateCreation,
),
),
),

FutureBuilder<int>(
future: _moutonRepository.getNombreMoutons(
bergerie.id,
),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Padding(
padding: EdgeInsets.symmetric(
vertical: 8,
),
child:
LinearProgressIndicator(),
);
}

final nombre =
snapshot.data ?? 0;

return ListTile(
dense: true,
contentPadding:
EdgeInsets.zero,
leading: const Icon(
Icons.pets,
color: Colors.green,
),
title: Text(
"$nombre ${nombre > 1 ? "moutons" : "mouton"}",
style: const TextStyle(
fontWeight:
FontWeight.bold,
),
),
);
},
),

const SizedBox(height: 15),
  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BergerieDetailsPage(
              bergerie: bergerie,
            ),
          ),
        );

        if (!mounted) return;

        if (result == true) {
          setState(() {
            _loadBergeries();
          });
        }
      },
      icon: const Icon(Icons.arrow_forward),
      label: const Text(
        "Ouvrir la bergerie",
      ),
    ),
  ),
],
),
),
);
},
);
},
),
);
}
}