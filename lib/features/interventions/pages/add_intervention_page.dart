import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../clients/models/client_model.dart';
import '../../clients/repositories/firebase_client_repository.dart';
import '../providers/intervention_provider.dart';
import '../models/intervention_model.dart';
class AddInterventionPage extends ConsumerStatefulWidget {
  final bool isEdition;
  final InterventionModel? intervention;

  const AddInterventionPage({
    super.key,
    this.isEdition = false,
    this.intervention,
  });
  @override
  ConsumerState<AddInterventionPage> createState() =>
      _AddInterventionPageState();
}

class _AddInterventionPageState
    extends ConsumerState<AddInterventionPage> {
final _formKey = GlobalKey<FormState>();

final FirebaseClientRepository _clientRepository =
FirebaseClientRepository();

final TextEditingController _dateController =
TextEditingController();

final TextEditingController _heureDebutController =
TextEditingController();

final TextEditingController _heureFinController =
TextEditingController();

final TextEditingController _agentController =
TextEditingController();

final TextEditingController _vehiculeController =
TextEditingController();

final TextEditingController _observationsController =
TextEditingController();

List<ClientModel> _clients = [];

ClientModel? _clientSelectionne;

bool _chargement = true;
bool _enregistrement = false;

bool _lavage = true;
bool _nettoyageBergerie = false;
bool _desinfection = false;

DateTime _dateIntervention = DateTime.now();

@override
void initState() {
super.initState();

_dateController.text =
    DateFormat('dd/MM/yyyy').format(_dateIntervention);

if (widget.isEdition &&
    widget.intervention != null) {

  final i = widget.intervention!;

  _dateIntervention = i.dateIntervention;

  _dateController.text =
      DateFormat('dd/MM/yyyy')
          .format(i.dateIntervention);

  _heureDebutController.text =
      i.heureDebut;

  _heureFinController.text =
      i.heureFin;

  _agentController.text =
      i.agent;

  _vehiculeController.text =
      i.vehicule;

  _observationsController.text =
      i.observations;

  _lavage = i.lavage;
  _nettoyageBergerie =
      i.nettoyageBergerie;
  _desinfection =
      i.desinfection;
}

_chargerClients();
}

Future<void> _chargerClients() async {
try {
final clients =
await _clientRepository.getClients();

clients.sort(
(a, b) => a.nom.compareTo(b.nom),
);

if (!mounted) return;

setState(() {
_clients = clients;
if (widget.isEdition &&
    widget.intervention != null) {

  _clientSelectionne =
      clients.firstWhere(
            (c) =>
        c.id ==
            widget.intervention!.clientId,
        orElse: () => clients.first,
      );
}
_chargement = false;
});
} catch (e) {
if (!mounted) return;

setState(() {
_chargement = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
"Erreur lors du chargement des clients : $e",
),
),
);
}
}

@override
void dispose() {
_dateController.dispose();
_heureDebutController.dispose();
_heureFinController.dispose();
_agentController.dispose();
_vehiculeController.dispose();
_observationsController.dispose();

super.dispose();
}
Future<void> _selectionnerDate() async {
final DateTime? date = await showDatePicker(
context: context,
initialDate: _dateIntervention,
firstDate: DateTime(2024),
lastDate: DateTime(2100),
locale: const Locale('fr', 'FR'),
);

if (date == null) return;

setState(() {
_dateIntervention = date;
_dateController.text =
DateFormat('dd/MM/yyyy').format(date);
});
}

Future<void> _selectionnerHeureDebut() async {
final heure = await showTimePicker(
context: context,
initialTime: TimeOfDay.now(),
);

if (heure == null) return;

_heureDebutController.text =
heure.format(context);

if (mounted) {
setState(() {});
}
}

Future<void> _selectionnerHeureFin() async {
final heure = await showTimePicker(
context: context,
initialTime: TimeOfDay.now(),
);

if (heure == null) return;

_heureFinController.text =
heure.format(context);

if (mounted) {
setState(() {});
}
}

Future<void> _enregistrer() async {
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

if (_heureDebutController.text.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Veuillez choisir l'heure de début.",
),
),
);
return;
}

if (_heureFinController.text.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Veuillez choisir l'heure de fin.",
),
),
);
return;
}

setState(() {
_enregistrement = true;
});

try {
  final notifier =
  ref.read(interventionProvider.notifier);

  if (widget.isEdition &&
      widget.intervention != null) {

    await notifier.modifierIntervention(

      widget.intervention!.copyWith(

        clientId: _clientSelectionne!.id,
        clientNom: _clientSelectionne!.nom,

        dateIntervention:
        _dateIntervention,

        heureDebut:
        _heureDebutController.text.trim(),

        heureFin:
        _heureFinController.text.trim(),

        lavage: _lavage,

        nettoyageBergerie:
        _nettoyageBergerie,

        desinfection:
        _desinfection,

        agent:
        _agentController.text.trim(),

        vehicule:
        _vehiculeController.text.trim(),

        nombreMoutons:
        _clientSelectionne!.nombreMoutons,

        observations:
        _observationsController.text.trim(),
      ),
    );

  } else {

    await notifier.ajouterIntervention(

      clientId:
      _clientSelectionne!.id,

      clientNom:
      _clientSelectionne!.nom,

      dateIntervention:
      _dateIntervention,

      heureDebut:
      _heureDebutController.text.trim(),

      heureFin:
      _heureFinController.text.trim(),

      lavage: _lavage,

      nettoyageBergerie:
      _nettoyageBergerie,

      desinfection:
      _desinfection,

      agent:
      _agentController.text.trim(),

      vehicule:
      _vehiculeController.text.trim(),

      nombreMoutons:
      _clientSelectionne!.nombreMoutons,

      observations:
      _observationsController.text.trim(),
    );
  }

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Intervention enregistrée avec succès.",
),
),
);

Navigator.of(context).pop(true);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
"Erreur : $e",
),
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
title: Text(
widget.isEdition
? "Modifier une intervention"
: "Nouvelle intervention",
),
),
body: _chargement
? const Center(
child: CircularProgressIndicator(),
)
: Form(
key: _formKey,
child: ListView(
padding: const EdgeInsets.all(16),
children: [

/// CLIENT
DropdownButtonFormField<ClientModel>(
value: _clientSelectionne,
decoration: const InputDecoration(
labelText: "Client",
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.person),
),
items: _clients
.map(
(client) => DropdownMenuItem(
value: client,
child: Text(client.nom),
),
)
.toList(),
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

if (_clientSelectionne != null)
Card(
child: Padding(
padding: const EdgeInsets.all(12),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

Text(
_clientSelectionne!.nom,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 18,
),
),

const SizedBox(height: 8),

Text(
"Téléphone : ${_clientSelectionne!.telephone}",
),

Text(
"Quartier : ${_clientSelectionne!.quartier}",
),

Text(
"Moutons : ${_clientSelectionne!.nombreMoutons}",
),

Text(
"Abonnement : ${_clientSelectionne!.abonnement}",
),
],
),
),
),

const SizedBox(height: 20),

/// DATE
TextFormField(
controller: _dateController,
readOnly: true,
decoration: InputDecoration(
labelText: "Date d'intervention",
border: const OutlineInputBorder(),
suffixIcon: IconButton(
icon: const Icon(Icons.calendar_month),
onPressed: _selectionnerDate,
),
),
),

const SizedBox(height: 16),

Row(
children: [

Expanded(
child: TextFormField(
controller:
_heureDebutController,
readOnly: true,
decoration: InputDecoration(
labelText: "Début",
border:
const OutlineInputBorder(),
suffixIcon: IconButton(
icon: const Icon(Icons.access_time),
onPressed:
_selectionnerHeureDebut,
),
),
),
),

const SizedBox(width: 12),

Expanded(
child: TextFormField(
controller:
_heureFinController,
readOnly: true,
decoration: InputDecoration(
labelText: "Fin",
border:
const OutlineInputBorder(),
suffixIcon: IconButton(
icon: const Icon(Icons.access_time),
onPressed:
_selectionnerHeureFin,
),
),
),
),
],
),

const SizedBox(height: 20),
  const Text(
    "Prestations",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),

  CheckboxListTile(
    value: _lavage,
    title: const Text("Lavage"),
    onChanged: (value) {
      setState(() {
        _lavage = value ?? false;
      });
    },
  ),

  CheckboxListTile(
    value: _nettoyageBergerie,
    title: const Text("Nettoyage de la bergerie"),
    onChanged: (value) {
      setState(() {
        _nettoyageBergerie = value ?? false;
      });
    },
  ),

  CheckboxListTile(
    value: _desinfection,
    title: const Text("Désinfection"),
    onChanged: (value) {
      setState(() {
        _desinfection = value ?? false;
      });
    },
  ),

  const SizedBox(height: 20),

  TextFormField(
    controller: _agentController,
    decoration: const InputDecoration(
      labelText: "Agent",
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.badge),
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return "Veuillez renseigner l'agent";
      }
      return null;
    },
  ),

  const SizedBox(height: 16),

  TextFormField(
    controller: _vehiculeController,
    decoration: const InputDecoration(
      labelText: "Véhicule",
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.local_shipping),
    ),
  ),

  const SizedBox(height: 16),

  TextFormField(
    controller: _observationsController,
    maxLines: 4,
    decoration: const InputDecoration(
      labelText: "Observations",
      border: OutlineInputBorder(),
      alignLabelWithHint: true,
    ),
  ),

  const SizedBox(height: 30),

  Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: _enregistrement
              ? null
              : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          label: const Text("Retour"),
        ),
      ),

      const SizedBox(width: 16),

      Expanded(
        child: ElevatedButton.icon(
          onPressed: _enregistrement
              ? null
              : _enregistrer,
          icon: _enregistrement
              ? const SizedBox(
            width: 18,
            height: 18,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : const Icon(Icons.save),
          label: Text(
            _enregistrement
                ? "Enregistrement..."
                : "Enregistrer",
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 30),
],
),
),
);
}
}