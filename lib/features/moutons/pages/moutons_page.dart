import 'package:flutter/material.dart';

import '../../../core/widgets/app_action_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/responsive_page.dart';

import '../../bergeries/models/bergerie_model.dart';
import '../models/mouton_model.dart';
import '../repository/firebase_mouton_repository.dart';
import '../widgets/mouton_card.dart';
import 'add_mouton_page.dart';
import 'mouton_details_page.dart';

class MoutonsPage extends StatefulWidget {
  final BergerieModel bergerie;

  const MoutonsPage({
    super.key,
    required this.bergerie,
  });

  @override
  State<MoutonsPage> createState() => _MoutonsPageState();
}

class _MoutonsPageState extends State<MoutonsPage> {
final FirebaseMoutonRepository _repository =
FirebaseMoutonRepository();

final TextEditingController _searchController =
TextEditingController();

late Future<List<MoutonModel>> _futureMoutons;

List<MoutonModel> _moutons = [];
List<MoutonModel> _moutonsFiltres = [];

@override
void initState() {
super.initState();

_chargerMoutons();

_searchController.addListener(_filtrerMoutons);
}

@override
void dispose() {
_searchController.removeListener(_filtrerMoutons);
_searchController.dispose();
super.dispose();
}

void _chargerMoutons() {
_futureMoutons =
_repository.getMoutonsByBergerie(widget.bergerie.id);
}

void _filtrerMoutons() {
final recherche =
_searchController.text.trim().toLowerCase();

setState(() {
if (recherche.isEmpty) {
_moutonsFiltres = List.from(_moutons);
return;
}

_moutonsFiltres = _moutons.where((mouton) {
return mouton.nom
.toLowerCase()
.contains(recherche) ||
mouton.numeroIdentification
.toLowerCase()
.contains(recherche) ||
mouton.race
.toLowerCase()
.contains(recherche);
}).toList();
});
}

Future<void> _ajouterMouton() async {
final resultat = await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => AddMoutonPage(
bergerie: widget.bergerie,
),
),
);

if (resultat == true && mounted) {
setState(() {
_chargerMoutons();
});
}
}

Future<void> _ouvrirDetails(
MoutonModel mouton,
) async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => MoutonDetailsPage(
mouton: mouton,
),
),
);

if (!mounted) return;

setState(() {
_chargerMoutons();
});
}

Future<void> _rafraichir() async {
setState(() {
_chargerMoutons();
});

await _futureMoutons;
}

@override
Widget build(BuildContext context) {
return ResponsivePage(
title: "Moutons - ${widget.bergerie.nom}",
child: FutureBuilder<List<MoutonModel>>(
future: _futureMoutons,
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: AppCard(
child: Padding(
padding: const EdgeInsets.all(30),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(
Icons.error_outline,
color: Colors.red,
size: 70,
),
const SizedBox(height: 20),
const Text(
"Une erreur est survenue",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 10),
Text(
snapshot.error.toString(),
textAlign: TextAlign.center,
),
],
),
),
),
);
}

_moutons = snapshot.data ?? [];

if (_searchController.text.isEmpty) {
_moutonsFiltres = List.from(_moutons);
} else {
WidgetsBinding.instance
.addPostFrameCallback((_) {
if (mounted) {
_filtrerMoutons();
}
});
}

final total = _moutons.length;

final beliers = _moutons.where((m) {
final sexe = m.sexe.toLowerCase();
return sexe == "male" ||
sexe == "mâle";
}).length;

final brebis = total - beliers;
return RefreshIndicator(
onRefresh: _rafraichir,
child: ListView(
padding: const EdgeInsets.all(20),
children: [

/// ==========================
/// Statistiques
/// ==========================

AppCard(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

Text(
widget.bergerie.nom,
style: const TextStyle(
fontSize: 22,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 8),

Text(
widget.bergerie.id,
style: TextStyle(
color: Colors.grey.shade600,
),
),

const SizedBox(height: 24),

Row(
children: [

Expanded(
child: _StatItem(
titre: "Moutons",
valeur: "$total",
icon: Icons.pets,
),
),

const SizedBox(width: 12),

Expanded(
child: _StatItem(
titre: "Béliers",
valeur: "$beliers",
icon: Icons.male,
),
),

const SizedBox(width: 12),

Expanded(
child: _StatItem(
titre: "Brebis",
valeur: "$brebis",
icon: Icons.female,
),
),
],
),
],
),
),

const SizedBox(height: 24),

/// ==========================
/// Recherche
/// ==========================

AppTextField(
controller: _searchController,
icon: Icons.search,
label: "Recherche",
),

const SizedBox(height: 20),

/// ==========================
/// Bouton Ajouter
/// ==========================

AppActionButton(
icon: Icons.add,
label: "Ajouter un mouton",
onPressed: _ajouterMouton,
),

const SizedBox(height: 24),

/// ==========================
/// Liste
/// ==========================

if (_moutonsFiltres.isEmpty)

AppCard(
child: Padding(
padding:
const EdgeInsets.symmetric(
vertical: 40,
horizontal: 20,
),
child: Column(
children: const [

Icon(
Icons.pets,
size: 80,
color: Colors.grey,
),

SizedBox(height: 20),

Text(
"Aucun mouton trouvé",
style: TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),

SizedBox(height: 10),

Text(
"Ajoutez un mouton ou modifiez votre recherche.",
textAlign:
TextAlign.center,
),
],
),
),
)
else

..._moutonsFiltres.map(
(mouton) => Padding(
padding:
const EdgeInsets.only(
bottom: 12,
),
child: MoutonCard(
mouton: mouton,
onTap: () =>
_ouvrirDetails(
mouton,
),
),
),
),
],
),
);
},
),
);
}
}

class _StatItem extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icon;

  const _StatItem({
    required this.titre,
    required this.valeur,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [

          CircleAvatar(
            radius: 22,
            backgroundColor:
            primary.withValues(alpha: 0.12),
            child: Icon(
              icon,
              color: primary,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            valeur,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

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
    );
  }
}