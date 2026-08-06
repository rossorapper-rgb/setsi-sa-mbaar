import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../clients/models/client_model.dart';
import '../../clients/repositories/firebase_client_repository.dart';
import '../providers/intervention_provider.dart';
import '../models/intervention_model.dart';
import '../widgets/intervention_client_section.dart';
import '../widgets/intervention_bergerie_section.dart';
import '../widgets/intervention_moutons_section.dart';
import '../widgets/intervention_planning_section.dart';
import '../widgets/intervention_prestations_section.dart';
import '../widgets/intervention_traitement_section.dart';
import '../../bergeries/models/bergerie_model.dart';
import '../../bergeries/repository/firebase_bergerie_repository.dart';
import '../../moutons/models/mouton_model.dart';
import '../../moutons/repository/firebase_mouton_repository.dart';
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

final FirebaseBergerieRepository _bergerieRepository =
FirebaseBergerieRepository();

List<BergerieModel> _bergeries = [];

BergerieModel? _bergerieSelectionnee;
final FirebaseMoutonRepository _moutonRepository =
FirebaseMoutonRepository();

List<MoutonModel> _moutons = [];

List<String> _moutonsSelectionnes = [];

bool _chargement = true;
bool _enregistrement = false;

bool _lavage = true;
bool _nettoyageBergerie = false;
bool _desinfection = false;
bool _traitementEnCours = false;

DateTime? _finTraitement;

final TextEditingController _maladieController =
TextEditingController();

final TextEditingController
_recommandationsController =
TextEditingController();

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
_maladieController.dispose();
_recommandationsController.dispose();
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

Future<void> _selectionnerFinTraitement() async {
  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: _finTraitement ?? DateTime.now(),
    firstDate: DateTime(2024),
    lastDate: DateTime(2100),
  );

  if (date == null) return;

  setState(() {
    _finTraitement = date;
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

        dateIntervention: _dateIntervention,

        heureDebut: _heureDebutController.text.trim(),

        heureFin: _heureFinController.text.trim(),

        lavage: _lavage,

        nettoyageBergerie: _nettoyageBergerie,

        desinfection: _desinfection,

        agent: _agentController.text.trim(),

        vehicule: _vehiculeController.text.trim(),

        bergerieId:
        _bergerieSelectionnee?.id ??
            widget.intervention!.bergerieId,

        bergerieNom:
        _bergerieSelectionnee?.nom ??
            widget.intervention!.bergerieNom,

        nombreMoutons:
        _clientSelectionne!.nombreMoutons,

        moutonsConcernes:
        _moutonsSelectionnes,

        traitementEnCours:
        _traitementEnCours,

        maladie:
        _maladieController.text.trim(),

        finTraitement:
        _finTraitement,

        recommandations:
        _recommandationsController.text.trim(),

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

      bergerieId: _bergerieSelectionnee?.id ?? "",
      bergerieNom: _bergerieSelectionnee?.nom ?? "",

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

  InterventionClientSection(
    clients: _clients,
    clientSelectionne: _clientSelectionne,
    onClientChanged: (client) async {
      setState(() {
        _clientSelectionne = client;
        _bergerieSelectionnee = null;
        _bergeries = [];
      });

      if (client == null) return;

      final liste = await _bergerieRepository
          .getBergeriesByClient(client.id);

      if (!mounted) return;

      setState(() {
        _bergeries = liste;
      });
    },
  ),

const SizedBox(height: 20),
  InterventionBergerieSection(
    bergeries: _bergeries,
    bergerieSelectionnee: _bergerieSelectionnee,
    onBergerieChanged: (bergerie) async {
      setState(() {
        _bergerieSelectionnee = bergerie;
        _moutons = [];
        _moutonsSelectionnes = [];
      });

      if (bergerie == null) return;

      final liste = await _moutonRepository
          .getMoutonsByBergerie(bergerie.id);

      if (!mounted) return;

      setState(() {
        _moutons = liste;
      });
    },
  ),

  const SizedBox(height: 20),
  InterventionMoutonsSection(
    moutons: _moutons,
    moutonsSelectionnes: _moutonsSelectionnes,
    onSelectionChanged: (selection) {
      setState(() {
        _moutonsSelectionnes = selection;
      });
    },
  ),

  const SizedBox(height: 20),
  InterventionPlanningSection(
    dateController: _dateController,
    heureDebutController: _heureDebutController,
    heureFinController: _heureFinController,
    agentController: _agentController,
    vehiculeController: _vehiculeController,
    onChoisirDate: _selectionnerDate,
    onChoisirHeureDebut: _selectionnerHeureDebut,
    onChoisirHeureFin: _selectionnerHeureFin,
  ),
  const SizedBox(height: 16),
  InterventionPrestationsSection(
    lavage: _lavage,
    nettoyageBergerie: _nettoyageBergerie,
    desinfection: _desinfection,

    vermifugation: false,
    produitVermifuge: "",
    prochaineVermifugation: null,

    onLavageChanged: (value) {
      setState(() {
        _lavage = value;
      });
    },

    onNettoyageChanged: (value) {
      setState(() {
        _nettoyageBergerie = value;
      });
    },

    onDesinfectionChanged: (value) {
      setState(() {
        _desinfection = value;
      });
    },

    onVermifugationChanged: (_) {},

    onChoisirDate: () {},

    produitController: TextEditingController(),
  ),
  const SizedBox(height: 16),

  InterventionTraitementSection(
    traitementEnCours: _traitementEnCours,
    maladieController: _maladieController,
    recommandationsController:
    _recommandationsController,
    finTraitement: _finTraitement,
    onTraitementChanged: (value) {
      setState(() {
        _traitementEnCours = value;
      });
    },
    onChoisirDate: _selectionnerFinTraitement,
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