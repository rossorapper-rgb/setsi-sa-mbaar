import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/mouton_model.dart';
import '../models/reproduction_model.dart';
import '../providers/mouton_provider.dart';
import '../providers/reproduction_provider.dart';

class ReproductionForm extends ConsumerStatefulWidget {
  final MoutonModel mouton;

  const ReproductionForm({
    super.key,
    required this.mouton,
  });

  @override
  ConsumerState<ReproductionForm> createState() =>
      _ReproductionFormState();
}

class _ReproductionFormState
    extends ConsumerState<ReproductionForm> {
final _formKey = GlobalKey<FormState>();

bool _loading = false;

bool _belierExterieur = false;

late DateTime _dateSaillie;

late DateTime _dateMiseBasPrevue;

MoutonModel? _belierSelectionne;

final TextEditingController _belierExterieurController =
TextEditingController();

final TextEditingController _proprietaireController =
TextEditingController();

final TextEditingController _observationController =
TextEditingController();

@override
void initState() {
super.initState();

_dateSaillie = DateTime.now();

_calculerDateMiseBas();
}

@override
void dispose() {
_belierExterieurController.dispose();
_proprietaireController.dispose();
_observationController.dispose();

super.dispose();
}

void _calculerDateMiseBas() {
_dateMiseBasPrevue =
_dateSaillie.add(const Duration(days: 150));
}

Future<void> _choisirDateSaillie() async {
final date = await showDatePicker(
context: context,
initialDate: _dateSaillie,
firstDate: DateTime(2020),
lastDate: DateTime(2035),
);

if (date == null) return;

setState(() {
_dateSaillie = date;
_calculerDateMiseBas();
});
}

Widget _sectionTitle(String titre) {
return Padding(
padding: const EdgeInsets.only(bottom: 12),
child: Text(
titre,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 18,
),
),
);
}

Widget _info(
String titre,
String valeur,
) {
return Padding(
padding: const EdgeInsets.symmetric(
vertical: 5,
),
child: Row(
children: [
SizedBox(
width: 120,
child: Text(
titre,
style: const TextStyle(
fontWeight: FontWeight.w600,
),
),
),
Expanded(
child: Text(valeur),
),
],
),
);
}

Future<void> _enregistrer() async {
if (!_formKey.currentState!.validate()) {
return;
}

if (!_belierExterieur &&
_belierSelectionne == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Veuillez sélectionner un bélier.",
),
),
);
return;
}

setState(() {
_loading = true;
});
try {
final repository = ref.read(
reproductionRepositoryProvider,
);

await repository.creerReproduction(
mouton: widget.mouton,
dateSaillie: _dateSaillie,

belierId: _belierExterieur
? ""
: _belierSelectionne!.id,

nomBelier: _belierExterieur
? _belierExterieurController.text.trim()
: _belierSelectionne!.nom,

raceBelier: _belierExterieur
? "Inconnue"
: _belierSelectionne!.race,

proprietaireBelier: _belierExterieur
? _proprietaireController.text.trim()
: "SET'SI",

observations:
_observationController.text.trim(),
);

ref.invalidate(
reproductionsProvider(widget.mouton.id),
);

ref.invalidate(
reproductionEnCoursProvider(
widget.mouton.id,
),
);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
backgroundColor: Colors.green,
content: Text(
"Reproduction enregistrée avec succès.",
),
),
);

Navigator.pop(context);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
backgroundColor: Colors.red,
content: Text(
e.toString(),
),
),
);
} finally {
if (mounted) {
setState(() {
_loading = false;
});
}
}
}

@override
Widget build(BuildContext context) {
final format =
DateFormat("dd/MM/yyyy");

final beliersAsync =
ref.watch(beliersProvider);

return Form(
key: _formKey,
child: ListView(
padding:
const EdgeInsets.all(16),
children: [

Card(
child: Padding(
padding:
const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

_sectionTitle("🐑 Brebis"),

Center(
child: CircleAvatar(
radius: 45,
child: const Icon(
Icons.pets,
size: 45,
),
),
),

const SizedBox(
height: 20,
),

_info(
"Nom",
widget.mouton.nom,
),

_info(
"Code",
widget.mouton.code,
),

_info(
"Race",
widget.mouton.race,
),

_info(
"Âge",
widget.mouton.ageTexte,
),
],
),
),
),

const SizedBox(height: 20),

Card(
child: Padding(
padding:
const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

_sectionTitle(
"📅 Saillie",
),

ListTile(
leading:
const Icon(
Icons.calendar_month,
),
title: Text(
format.format(
_dateSaillie,
),
),
trailing:
const Icon(
Icons.edit,
),
onTap:
_choisirDateSaillie,
),
],
),
),
),

const SizedBox(height: 20),
Card(
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

_sectionTitle("🐏 Bélier"),

SwitchListTile(
title: const Text(
"Bélier extérieur",
),
value: _belierExterieur,
onChanged: (value) {
setState(() {
_belierExterieur = value;
_belierSelectionne = null;
});
},
),

const SizedBox(height: 10),

if (_belierExterieur) ...[

TextFormField(
controller:
_belierExterieurController,
decoration:
const InputDecoration(
labelText:
"Nom du bélier",
border:
OutlineInputBorder(),
),
validator: (value) {
if (!_belierExterieur) {
return null;
}

if (value == null ||
value.trim().isEmpty) {
return "Veuillez saisir le nom du bélier";
}

return null;
},
),

const SizedBox(height: 15),

TextFormField(
controller:
_proprietaireController,
decoration:
const InputDecoration(
labelText:
"Propriétaire",
border:
OutlineInputBorder(),
),
),

] else ...[

beliersAsync.when(

data: (beliers) {

if (beliers.isEmpty) {
return const Text(
"Aucun bélier disponible.",
);
}

return DropdownButtonFormField<MoutonModel>(
value: _belierSelectionne,
isExpanded: true,
decoration:
const InputDecoration(
border:
OutlineInputBorder(),
labelText:
"Sélectionner un bélier",
),
items: beliers
.map(
(belier) =>
DropdownMenuItem<
MoutonModel>(
value: belier,
child: Text(
"${belier.code} - ${belier.nom}",
),
),
)
.toList(),
onChanged: (value) {
setState(() {
_belierSelectionne =
value;
});
},
validator: (_) {
if (_belierSelectionne ==
null) {
return "Veuillez sélectionner un bélier";
}

return null;
},
);
},

loading: () =>
const Center(
child:
CircularProgressIndicator(),
),

error: (e, _) => Text(
e.toString(),
),
),

],
],
),
),
),

const SizedBox(height: 20),

Card(
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

_sectionTitle(
"📊 Résumé",
),

_info(
"Gestation",
"150 jours",
),

_info(
"Date prévue",
format.format(
_dateMiseBasPrevue,
),
),

_info(
"Statut",
"Gestation",
),
],
),
),
),

const SizedBox(height: 20),
  Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            "📝 Observations",
          ),

          TextFormField(
            controller:
            _observationController,
            maxLines: 5,
            decoration:
            const InputDecoration(
              hintText:
              "Observations éventuelles...",
              border:
              OutlineInputBorder(),
            ),
          ),
        ],
      ),
    ),
  ),

  const SizedBox(height: 30),

  Row(
    children: [

      Expanded(
        child: OutlinedButton(
          onPressed: _loading
              ? null
              : () {
            Navigator.pop(context);
          },
          child: const Text(
            "ANNULER",
          ),
        ),
      ),

      const SizedBox(width: 15),

      Expanded(
        child: FilledButton(
          onPressed: _loading
              ? null
              : _enregistrer,
          child: _loading
              ? const SizedBox(
            width: 22,
            height: 22,
            child:
            CircularProgressIndicator(
              strokeWidth: 2.5,
            ),
          )
              : const Text(
            "ENREGISTRER",
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 30),
],
),
);
}
}