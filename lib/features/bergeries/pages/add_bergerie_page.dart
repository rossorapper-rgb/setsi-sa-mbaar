import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/widgets/app_back_bar.dart';
import '../models/bergerie_model.dart';
import '../repository/firebase_bergerie_repository.dart';

class AddBergeriePage extends StatefulWidget {
  const AddBergeriePage({super.key});

  @override
  State<AddBergeriePage> createState() => _AddBergeriePageState();
}

class _AddBergeriePageState extends State<AddBergeriePage> {
final _formKey = GlobalKey<FormState>();

final _nomController = TextEditingController();
final _adresseController = TextEditingController();
final _telephoneController = TextEditingController();
final _responsableController = TextEditingController();
final _observationsController = TextEditingController();

final FirebaseBergerieRepository _repository =
FirebaseBergerieRepository();

final Uuid _uuid = const Uuid();

bool _isSaving = false;

@override
void dispose() {
_nomController.dispose();
_adresseController.dispose();
_telephoneController.dispose();
_responsableController.dispose();
_observationsController.dispose();
super.dispose();
}

Future<void> _saveBergerie() async {
debugPrint("===== Début sauvegarde =====");

if (!_formKey.currentState!.validate()) {
debugPrint("❌ Formulaire invalide");
return;
}

setState(() {
_isSaving = true;
});

try {
final bergerie = BergerieModel(
id: _uuid.v4(),
clientId: "",
nom: _nomController.text.trim(),
adresse: _adresseController.text.trim(),
telephone: _telephoneController.text.trim(),
responsable: _responsableController.text.trim(),
observations: _observationsController.text.trim(),
latitude: null,
longitude: null,
active: true,
dateCreation: DateTime.now(),
dateModification: null,
);

debugPrint("📤 Envoi vers Firebase...");

await _repository.addBergerie(bergerie);

debugPrint("✅ Bergerie enregistrée.");

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("Bergerie enregistrée avec succès."),
backgroundColor: Colors.green,
),
);

Navigator.pop(context, true);
} catch (e, stackTrace) {
debugPrint("🔥 ERREUR : $e");
debugPrint(stackTrace.toString());

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("Erreur : $e"),
backgroundColor: Colors.red,
),
);
} finally {
if (mounted) {
setState(() {
_isSaving = false;
});
}
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: const AppBackBar(
title: "Nouvelle bergerie",
),
body: Form(
key: _formKey,
child: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
"Informations générales",
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

TextFormField(
controller: _nomController,
decoration: const InputDecoration(
labelText: "Nom de la bergerie",
prefixIcon: Icon(Icons.home_work),
border: OutlineInputBorder(),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "Veuillez saisir le nom de la bergerie";
}
return null;
},
),

const SizedBox(height: 16),

TextFormField(
controller: _adresseController,
decoration: const InputDecoration(
labelText: "Adresse",
prefixIcon: Icon(Icons.location_on),
border: OutlineInputBorder(),
),
),

const SizedBox(height: 16),

TextFormField(
controller: _telephoneController,
keyboardType: TextInputType.phone,
decoration: const InputDecoration(
labelText: "Téléphone",
prefixIcon: Icon(Icons.phone),
border: OutlineInputBorder(),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "Veuillez saisir un numéro";
}
return null;
},
),

const SizedBox(height: 16),

TextFormField(
controller: _responsableController,
decoration: const InputDecoration(
labelText: "Responsable",
prefixIcon: Icon(Icons.person),
border: OutlineInputBorder(),
),
),

const SizedBox(height: 16),

TextFormField(
controller: _observationsController,
maxLines: 4,
decoration: const InputDecoration(
labelText: "Observations",
alignLabelWithHint: true,
border: OutlineInputBorder(),
),
),
  const SizedBox(height: 30),

  SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton.icon(
      onPressed: _isSaving ? null : _saveBergerie,
      icon: _isSaving
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : const Icon(Icons.save),
      label: Text(
        _isSaving
            ? "Enregistrement..."
            : "Enregistrer la bergerie",
      ),
    ),
  ),
],
),
),
),
);
}
}