import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/widgets/app_action_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_date_field.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/responsive_page.dart';

import '../../bergeries/models/bergerie_model.dart';
import '../models/mouton_model.dart';
import '../repository/firebase_mouton_repository.dart';

class AddMoutonPage extends StatefulWidget {
  final BergerieModel bergerie;
  final MoutonModel? mouton;

  const AddMoutonPage({
    super.key,
    required this.bergerie,
    this.mouton,
  });

  @override
  State<AddMoutonPage> createState() =>
      _AddMoutonPageState();
}

class _AddMoutonPageState
    extends State<AddMoutonPage> {
final GlobalKey<FormState> _formKey =
GlobalKey<FormState>();

final FirebaseMoutonRepository
_repository =
FirebaseMoutonRepository();

final Uuid _uuid = const Uuid();

final TextEditingController
_nomController =
TextEditingController();

final TextEditingController
_numeroController =
TextEditingController();

final TextEditingController
_poidsController =
TextEditingController();

final TextEditingController
_couleurController =
TextEditingController();

DateTime? _dateNaissance;

String _race = "Ladoum";
String _sexe = "Mâle";

bool _loading = false;

static final List<
DropdownMenuItem<String>> races = [
const DropdownMenuItem(
value: "Ladoum",
child: Text("Ladoum"),
),
const DropdownMenuItem(
value: "Bali-Bali",
child: Text("Bali-Bali"),
),
const DropdownMenuItem(
value: "Touabire",
child: Text("Touabire"),
),
const DropdownMenuItem(
value: "Waralé",
child: Text("Waralé"),
),
const DropdownMenuItem(
value: "Croisé",
child: Text("Croisé"),
),
const DropdownMenuItem(
value: "Autre",
child: Text("Autre"),
),
];

static final List<
DropdownMenuItem<String>> sexes = [
const DropdownMenuItem(
value: "Mâle",
child: Text("Mâle"),
),
const DropdownMenuItem(
value: "Femelle",
child: Text("Femelle"),
),
];

@override
void initState() {
super.initState();

if (widget.mouton != null) {
_chargerMouton();
} else {
_numeroController.text =
_genererNumeroIdentification();
}
}

@override
void dispose() {
_nomController.dispose();
_numeroController.dispose();
_poidsController.dispose();
_couleurController.dispose();
super.dispose();
}

void _chargerMouton() {
final mouton = widget.mouton!;

_nomController.text = mouton.nom;
_numeroController.text =
mouton.numeroIdentification;

_poidsController.text =
mouton.poids.toString();

_couleurController.text =
mouton.couleur;

_race = mouton.race;
_sexe = mouton.sexe;

_dateNaissance =
mouton.dateNaissance;
}

String _genererNumeroIdentification() {
final now = DateTime.now();

final numero =
now.millisecondsSinceEpoch
.toString()
.substring(7);

return "MTN-${now.year}-$numero";
}

int? get _ageEnMois {
if (_dateNaissance == null) {
return null;
}

final now = DateTime.now();

return ((now.year -
_dateNaissance!.year) *
12) +
(now.month -
_dateNaissance!.month);
}

String get _texteAge {
final age = _ageEnMois;

if (age == null) {
return "Non renseigné";
}

if (age < 12) {
return "$age mois";
}

final ans = age ~/ 12;
final mois = age % 12;

if (mois == 0) {
return "$ans an${ans > 1 ? "s" : ""}";
}

return "$ans an${ans > 1 ? "s" : ""} $mois mois";
}

Future<void> _choisirDate() async {
final date = await showDatePicker(
context: context,
initialDate:
_dateNaissance ??
DateTime.now(),
firstDate: DateTime(2015),
lastDate: DateTime.now(),
);

if (date == null) return;

setState(() {
_dateNaissance = date;
});
}
@override
Widget build(BuildContext context) {
return ResponsivePage(
title: widget.mouton == null
? "Ajouter un mouton"
: "Modifier le mouton",
child: Form(
key: _formKey,
child: ListView(
padding: const EdgeInsets.all(20),
children: [

AppCard(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

const Text(
"Identification",
style: TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 20),

AppTextField(
controller:
_nomController,
label:
"Nom du mouton",
icon: Icons.pets,
),

const SizedBox(height: 18),

AppTextField(
controller:
_numeroController,
label:
"Numéro d'identification",
icon: Icons.qr_code,
),
],
),
),

const SizedBox(height: 20),

AppCard(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

const Text(
"Caractéristiques",
style: TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 20),

AppDropdown<String>(
label: "Race",
value: _race,
icon: Icons.category,
items: races,
onChanged: (value) {
if (value == null) {
return;
}

setState(() {
_race = value;
});
},
),

const SizedBox(height: 18),

AppDropdown<String>(
label: "Sexe",
value: _sexe,
icon: Icons.male,
items: sexes,
onChanged: (value) {
if (value == null) {
return;
}

setState(() {
_sexe = value;
});
},
),

const SizedBox(height: 18),

AppTextField(
controller:
_poidsController,
label: "Poids (Kg)",
icon: Icons
.monitor_weight_outlined,
),

const SizedBox(height: 18),

AppTextField(
controller:
_couleurController,
label: "Couleur",
icon: Icons.palette,
),

const SizedBox(height: 18),

AppDateField(
label:
"Date de naissance",
value:
_dateNaissance,
onTap:
_choisirDate,
),

const SizedBox(height: 20),

Container(
width: double.infinity,
padding:
const EdgeInsets.all(
16),
decoration:
BoxDecoration(
color: Theme.of(
context)
.colorScheme
.primary
.withValues(
alpha: 0.05),
borderRadius:
BorderRadius
.circular(12),
),
child: Row(
children: [

Icon(
Icons.cake,
color: Theme.of(
context)
.colorScheme
.primary,
),

const SizedBox(
width: 12,
),

Expanded(
child: Text(
"Âge : $_texteAge",
style:
const TextStyle(
fontWeight:
FontWeight
.w600,
),
),
),
],
),
),
],
),
),

const SizedBox(height: 30),

AppActionButton(
label: widget.mouton ==
null
? "Enregistrer"
: "Mettre à jour",
icon: Icons.save,
isLoading: _loading,
onPressed: _loading
? null
: _enregistrer,
),
],
),
),
);
}
Future<void> _enregistrer() async {
  if (_nomController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Veuillez saisir le nom du mouton.",
        ),
      ),
    );
    return;
  }

  if (_numeroController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Veuillez saisir le numéro d'identification.",
        ),
      ),
    );
    return;
  }

  if (_dateNaissance == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Veuillez sélectionner une date de naissance.",
        ),
      ),
    );
    return;
  }

  setState(() {
    _loading = true;
  });

  try {
    final mouton = MoutonModel(
      id: widget.mouton?.id ?? _uuid.v4(),
      bergerieId: widget.bergerie.id,
      nom: _nomController.text.trim(),
      numeroIdentification:
      _numeroController.text.trim(),
      race: _race,
      sexe: _sexe,
      dateNaissance: _dateNaissance!,
      poids: _poidsController.text.trim().isEmpty
          ? 0
          : double.tryParse(
          _poidsController.text
              .replaceAll(",", ".")) ??
          0,
      couleur:
      _couleurController.text.trim(),
      photoUrl:
      widget.mouton?.photoUrl ?? "",
      actif:
      widget.mouton?.actif ?? true,
      dateCreation:
      widget.mouton?.dateCreation ??
          DateTime.now(),
    );

    if (widget.mouton == null) {
      await _repository.addMouton(
        mouton,
      );
    } else {
      await _repository.updateMouton(
        mouton,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          widget.mouton == null
              ? "Le mouton a été ajouté avec succès."
              : "Le mouton a été mis à jour avec succès.",
        ),
      ),
    );

    Navigator.pop(context, true);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Une erreur est survenue : $e",
        ),
      ),
    );
  } finally {
    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }
}
}