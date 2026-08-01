import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/widgets/app_back_bar.dart';

import '../../clients/models/client_model.dart';
import '../../clients/repositories/firebase_client_repository.dart';

import '../models/bergerie_model.dart';
import '../repository/firebase_bergerie_repository.dart';

class AddBergeriePage extends StatefulWidget {
  final bool isEdition;
  final BergerieModel? bergerie;

  const AddBergeriePage({
    super.key,
    this.isEdition = false,
    this.bergerie,
  });

  @override
  State<AddBergeriePage> createState() =>
      _AddBergeriePageState();
}

class _AddBergeriePageState
    extends State<AddBergeriePage> {
final _formKey = GlobalKey<FormState>();

final _nomController = TextEditingController();
final _adresseController = TextEditingController();
final _telephoneController =
TextEditingController();
final _responsableController =
TextEditingController();
final _observationsController =
TextEditingController();

final FirebaseBergerieRepository _repository =
FirebaseBergerieRepository();

final FirebaseClientRepository _clientRepository =
FirebaseClientRepository();

final Uuid _uuid = const Uuid();

List<ClientModel> _clients = [];

ClientModel? _clientSelectionne;

bool _isSaving = false;
bool _isLoadingClients = true;
@override
void initState() {
super.initState();

if (widget.isEdition && widget.bergerie != null) {
_nomController.text = widget.bergerie!.nom;
_adresseController.text = widget.bergerie!.adresse;
_telephoneController.text = widget.bergerie!.telephone;
_responsableController.text =
widget.bergerie!.responsable;
_observationsController.text =
widget.bergerie!.observations;
}

_chargerClients();
}

Future<void> _chargerClients() async {
try {
final clients = await _clientRepository.getClients();

if (!mounted) return;

ClientModel? clientSelectionne;

if (widget.isEdition &&
widget.bergerie != null &&
widget.bergerie!.clientId.isNotEmpty) {
try {
clientSelectionne = clients.firstWhere(
(c) => c.id == widget.bergerie!.clientId,
);
} catch (_) {
clientSelectionne = null;
}
}

setState(() {
_clients = clients;
_clientSelectionne = clientSelectionne;
_isLoadingClients = false;
});
} catch (e) {
if (!mounted) return;

setState(() {
_isLoadingClients = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
"Impossible de charger les clients.\n$e",
),
),
);
}
}

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
if (!_formKey.currentState!.validate()) {
return;
}

if (_clientSelectionne == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Veuillez sélectionner un client.",
),
),
);
return;
}

setState(() {
_isSaving = true;
});

try {
final bergerie = BergerieModel(
id: widget.isEdition
? widget.bergerie!.id
: _uuid.v4(),

clientId: _clientSelectionne!.id,

nom: _nomController.text.trim(),
adresse: _adresseController.text.trim(),
telephone: _telephoneController.text.trim(),
responsable:
_responsableController.text.trim(),
observations:
_observationsController.text.trim(),

latitude: widget.isEdition
? widget.bergerie!.latitude
: null,

longitude: widget.isEdition
? widget.bergerie!.longitude
: null,

active: widget.isEdition
? widget.bergerie!.active
: true,

dateCreation: widget.isEdition
? widget.bergerie!.dateCreation
: DateTime.now(),

dateModification: DateTime.now(),
);

if (widget.isEdition) {
await _repository.updateBergerie(bergerie);
} else {
await _repository.addBergerie(bergerie);
}

if (!mounted) return;

Navigator.pop(context, true);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
backgroundColor: Colors.red,
content: Text("Erreur : $e"),
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
appBar: AppBackBar(
title: widget.isEdition
? "Modifier la bergerie"
: "Nouvelle bergerie",
),
body: Form(
key: _formKey,
child: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
"Informations générales",
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

if (_isLoadingClients)
const Center(
child: Padding(
padding: EdgeInsets.symmetric(
vertical: 20,
),
child:
CircularProgressIndicator(),
),
)
else
DropdownButtonFormField<ClientModel>(
value: _clientSelectionne,
decoration:
const InputDecoration(
labelText: "Client *",
prefixIcon:
Icon(Icons.person),
border:
OutlineInputBorder(),
),
items: _clients.map((client) {
return DropdownMenuItem<
ClientModel>(
value: client,
child: Text(client.nom),
);
}).toList(),
onChanged: (client) {
setState(() {
_clientSelectionne = client;
});
},
validator: (value) {
if (value == null) {
return "Veuillez sélectionner un client";
}
return null;
},
),

const SizedBox(height: 16),

TextFormField(
controller: _nomController,
decoration:
const InputDecoration(
labelText:
"Nom de la bergerie",
prefixIcon:
Icon(Icons.home_work),
border:
OutlineInputBorder(),
),
validator: (value) {
if (value == null ||
value.trim().isEmpty) {
return "Veuillez saisir le nom";
}
return null;
},
),

const SizedBox(height: 16),

TextFormField(
controller: _adresseController,
decoration:
const InputDecoration(
labelText: "Adresse",
prefixIcon:
Icon(Icons.location_on),
border:
OutlineInputBorder(),
),
),

const SizedBox(height: 16),

TextFormField(
controller: _telephoneController,
keyboardType:
TextInputType.phone,
decoration:
const InputDecoration(
labelText: "Téléphone",
prefixIcon:
Icon(Icons.phone),
border:
OutlineInputBorder(),
),
validator: (value) {
if (value == null ||
value.trim().isEmpty) {
return "Veuillez saisir le téléphone";
}
return null;
},
),

const SizedBox(height: 16),

TextFormField(
controller:
_responsableController,
decoration:
const InputDecoration(
labelText: "Responsable",
prefixIcon:
Icon(Icons.badge),
border:
OutlineInputBorder(),
),
),

const SizedBox(height: 16),

TextFormField(
controller:
_observationsController,
maxLines: 4,
decoration:
const InputDecoration(
labelText: "Observations",
alignLabelWithHint: true,
border:
OutlineInputBorder(),
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
          : Icon(
        widget.isEdition
            ? Icons.edit
            : Icons.save,
      ),
      label: Text(
        _isSaving
            ? (widget.isEdition
            ? "Modification..."
            : "Enregistrement...")
            : (widget.isEdition
            ? "Modifier la bergerie"
            : "Enregistrer la bergerie"),
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