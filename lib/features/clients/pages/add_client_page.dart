import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/client_model.dart';
import '../providers/client_provider.dart';

class AddClientPage extends ConsumerStatefulWidget {
  const AddClientPage({super.key});

  @override
  ConsumerState<AddClientPage> createState() =>
      _AddClientPageState();
}

class _AddClientPageState
    extends ConsumerState<AddClientPage> {
final _formKey = GlobalKey<FormState>();

final _nomController = TextEditingController();
final _telephoneController = TextEditingController();
final _quartierController = TextEditingController();
final _adresseController = TextEditingController();
final _troupeauxController =
TextEditingController(text: '0');
final _moutonsController =
TextEditingController(text: '0');

String _abonnement = "Essentiel";
bool _actif = true;
bool _enregistrement = false;

@override
void dispose() {
_nomController.dispose();
_telephoneController.dispose();
_quartierController.dispose();
_adresseController.dispose();
_troupeauxController.dispose();
_moutonsController.dispose();
super.dispose();
}

InputDecoration _decoration(
String label,
IconData icon,
) {
return InputDecoration(
labelText: label,
prefixIcon: Icon(icon),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
);
}

Future<void> _enregistrer() async {
if (!_formKey.currentState!.validate()) {
return;
}

setState(() {
_enregistrement = true;
});

try {
final client = ClientModel(
id: DateTime.now()
.millisecondsSinceEpoch
.toString(),
nom: _nomController.text.trim(),
telephone:
_telephoneController.text.trim(),
quartier:
_quartierController.text.trim(),
adresse:
_adresseController.text.trim(),
nombreTroupeaux: int.tryParse(
_troupeauxController.text,
) ??
0,
nombreMoutons: int.tryParse(
_moutonsController.text,
) ??
0,
abonnement: _abonnement,
actif: _actif,
);

await ref
.read(clientNotifierProvider.notifier)
.ajouterClient(client);
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Client enregistré avec succès.",
),
backgroundColor: Colors.green,
),
);

Navigator.pop(context);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
"Erreur : $e",
),
backgroundColor: Colors.red,
),
);
} finally {
if (mounted) {
setState(() {
_enregistrement = false;
});
}
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("Nouveau client"),
centerTitle: true,
),
body: Form(
key: _formKey,
child: ListView(
padding: const EdgeInsets.all(24),
children: [
const Text(
"Informations générales",
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 24),

TextFormField(
controller: _nomController,
decoration: _decoration(
"Nom complet",
Icons.person,
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "Veuillez saisir le nom";
}
return null;
},
),

const SizedBox(height: 16),

TextFormField(
controller: _telephoneController,
keyboardType: TextInputType.phone,
decoration: _decoration(
"Téléphone",
Icons.phone,
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "Veuillez saisir le téléphone";
}
return null;
},
),

const SizedBox(height: 16),

TextFormField(
controller: _quartierController,
decoration: _decoration(
"Quartier",
Icons.location_on,
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "Veuillez saisir le quartier";
}
return null;
},
),
  const SizedBox(height: 16),

  TextFormField(
    controller: _adresseController,
    maxLines: 2,
    decoration: _decoration(
      "Adresse",
      Icons.home,
    ),
  ),

  const SizedBox(height: 16),

  Row(
    children: [
      Expanded(
        child: TextFormField(
          controller: _troupeauxController,
          keyboardType: TextInputType.number,
          decoration: _decoration(
            "Nombre de troupeaux",
            Icons.home_work,
          ),
        ),
      ),

      const SizedBox(width: 16),

      Expanded(
        child: TextFormField(
          controller: _moutonsController,
          keyboardType: TextInputType.number,
          decoration: _decoration(
            "Nombre de moutons",
            Icons.pets,
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 20),

  DropdownButtonFormField<String>(
    value: _abonnement,
    decoration: _decoration(
      "Abonnement",
      Icons.workspace_premium,
    ),
    items: const [
      DropdownMenuItem(
        value: "Essentiel",
        child: Text("Essentiel"),
      ),
      DropdownMenuItem(
        value: "Confort",
        child: Text("Confort"),
      ),
      DropdownMenuItem(
        value: "Prestige",
        child: Text("Prestige"),
      ),
    ],
    onChanged: (value) {
      if (value == null) return;

      setState(() {
        _abonnement = value;
      });
    },
  ),

  const SizedBox(height: 20),

  SwitchListTile(
    value: _actif,
    title: const Text("Client actif"),
    secondary: const Icon(
      Icons.verified_user,
    ),
    onChanged: (value) {
      setState(() {
        _actif = value;
      });
    },
  ),

  const SizedBox(height: 32),

  FilledButton.icon(
    onPressed:
    _enregistrement ? null : _enregistrer,
    icon: _enregistrement
        ? const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    )
        : const Icon(Icons.save),
    label: Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Text(
        _enregistrement
            ? "Enregistrement..."
            : "Enregistrer",
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    ),
  ),

  const SizedBox(height: 12),

  OutlinedButton.icon(
    onPressed: _enregistrement
        ? null
        : () => Navigator.pop(context),
    icon: const Icon(
      Icons.arrow_back,
    ),
    label: const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Text("Annuler"),
    ),
  ),
],
),
),
);
}
}
