import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../bergeries/models/bergerie_model.dart';
import '../../bergeries/repository/firebase_bergerie_repository.dart';
import '../../clients/models/client_model.dart';
import '../../clients/repositories/firebase_client_repository.dart';

import '../models/paiement_model.dart';
import '../providers/paiement_provider.dart';

class AddPaiementPage extends ConsumerStatefulWidget {
  final bool isEdition;
  final PaiementModel? paiement;

  const AddPaiementPage({
    super.key,
    this.isEdition = false,
    this.paiement,
  });

  @override
  ConsumerState<AddPaiementPage> createState() =>
      _AddPaiementPageState();
}

class _AddPaiementPageState
    extends ConsumerState<AddPaiementPage> {
final _formKey = GlobalKey<FormState>();

final FirebaseClientRepository _clientRepository =
FirebaseClientRepository();

final FirebaseBergerieRepository
_bergerieRepository =
FirebaseBergerieRepository();

bool _chargement = true;
bool _enregistrement = false;

List<ClientModel> _clients = [];
ClientModel? _clientSelectionne;

List<BergerieModel> _bergeries = [];
BergerieModel? _bergerieSelectionnee;

final TextEditingController
_dateController = TextEditingController();

final TextEditingController
_montantConseilleController =
TextEditingController();

final TextEditingController
_montantFactureController =
TextEditingController();

final TextEditingController
_montantPayeController =
TextEditingController();

final TextEditingController
_referenceController =
TextEditingController();

final TextEditingController
_motifRemiseController =
TextEditingController();

final TextEditingController
_observationsController =
TextEditingController();

DateTime _datePaiement = DateTime.now();

TypePrestation _typePrestation =
TypePrestation.lavage;

ModePaiement _modePaiement =
ModePaiement.especes;

@override
void initState() {
super.initState();

_dateController.text =
DateFormat("dd/MM/yyyy")
.format(_datePaiement);

if (widget.isEdition &&
widget.paiement != null) {
final p = widget.paiement!;

_datePaiement = p.datePaiement;

_dateController.text =
DateFormat("dd/MM/yyyy")
.format(p.datePaiement);

_typePrestation =
p.typePrestation;

_modePaiement =
p.modePaiement;

_montantConseilleController.text =
p.montantConseille
.toStringAsFixed(0);

_montantFactureController.text =
p.montantFacture
.toStringAsFixed(0);

_montantPayeController.text =
p.montantPaye
.toStringAsFixed(0);

_referenceController.text =
p.reference;

_motifRemiseController.text =
p.motifRemise;

_observationsController.text =
p.observations;
}

_chargerClients();
}

Future<void> _chargerClients() async {
try {
final clients =
await _clientRepository
.getClients();

clients.sort(
(a, b) =>
a.nom.compareTo(b.nom),
);

if (!mounted) return;

setState(() {
_clients = clients;

if (widget.isEdition &&
widget.paiement != null) {
_clientSelectionne =
clients.firstWhere(
(c) =>
c.id ==
widget.paiement!
.clientId,
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

ScaffoldMessenger.of(context)
.showSnackBar(
SnackBar(
content:
Text("Erreur : $e"),
),
);
}
}

@override
void dispose() {
_dateController.dispose();
_montantConseilleController.dispose();
_montantFactureController.dispose();
_montantPayeController.dispose();
_referenceController.dispose();
_motifRemiseController.dispose();
_observationsController.dispose();

super.dispose();
}

Future<void> _selectionnerDate() async {
final date =
await showDatePicker(
context: context,
initialDate: _datePaiement,
firstDate: DateTime(2024),
lastDate: DateTime(2100),
locale: const Locale("fr", "FR"),
);

if (date == null) return;

setState(() {
_datePaiement = date;

_dateController.text =
DateFormat("dd/MM/yyyy")
.format(date);
});
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

setState(() {
_enregistrement = true;
});

try {
final notifier =
ref.read(paiementProvider.notifier);

final montantConseille =
double.tryParse(
_montantConseilleController.text
.replaceAll(',', '.'),
) ??
0;

final montantFacture =
double.tryParse(
_montantFactureController.text
.replaceAll(',', '.'),
) ??
0;

final montantPaye =
double.tryParse(
_montantPayeController.text
.replaceAll(',', '.'),
) ??
0;

if (widget.isEdition &&
widget.paiement != null) {
await notifier.modifierPaiement(
widget.paiement!.copyWith(
clientId: _clientSelectionne!.id,
clientNom: _clientSelectionne!.nom,

bergerieId:
_bergerieSelectionnee?.id ??
widget.paiement!.bergerieId,

bergerieNom:
_bergerieSelectionnee?.nom ??
widget.paiement!.bergerieNom,

typePrestation:
_typePrestation,

montantConseille:
montantConseille,

montantFacture:
montantFacture,

montantPaye:
montantPaye,

modePaiement:
_modePaiement,

reference:
_referenceController.text
.trim(),

motifRemise:
_motifRemiseController.text
.trim(),

observations:
_observationsController.text
.trim(),

datePaiement:
_datePaiement,
),
);
} else {
await notifier.ajouterPaiement(
clientId:
_clientSelectionne!.id,

clientNom:
_clientSelectionne!.nom,

bergerieId:
_bergerieSelectionnee?.id ??
"",

bergerieNom:
_bergerieSelectionnee?.nom ??
"",

typePrestation:
_typePrestation,

montantConseille:
montantConseille,

montantFacture:
montantFacture,

montantPaye:
montantPaye,

modePaiement:
_modePaiement,

reference:
_referenceController.text
.trim(),

motifRemise:
_motifRemiseController.text
.trim(),

observations:
_observationsController.text
.trim(),

creePar:
"Administrateur",

datePaiement:
_datePaiement,
);
}

if (!mounted) return;

ScaffoldMessenger.of(context)
.showSnackBar(
const SnackBar(
content: Text(
"Paiement enregistré avec succès.",
),
),
);

Navigator.pop(context, true);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context)
.showSnackBar(
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
? "Modifier un paiement"
: "Nouveau paiement",
),
),
body: _chargement
? const Center(
child:
CircularProgressIndicator(),
)
: Form(
key: _formKey,
child: ListView(
padding:
const EdgeInsets.all(16),
children: [

DropdownButtonFormField<ClientModel>(
value:
_clientSelectionne,
decoration:
const InputDecoration(
labelText:
"Client",
border:
OutlineInputBorder(),
),
items: _clients
.map(
(client) =>
DropdownMenuItem(
value: client,
child:
Text(client.nom),
),
)
.toList(),
onChanged:
(client) async {
setState(() {
_clientSelectionne =
client;

_bergerieSelectionnee =
null;

_bergeries = [];
});

if (client == null) {
return;
}

final liste =
await _bergerieRepository
.getBergeriesByClient(
client.id,
);

if (!mounted) return;

setState(() {
_bergeries =
liste;
});
},
),

const SizedBox(height: 20),

DropdownButtonFormField<BergerieModel>(
value:
_bergerieSelectionnee,
decoration:
const InputDecoration(
labelText:
"Bergerie",
border:
OutlineInputBorder(),
),
items: _bergeries
.map(
(bergerie) =>
DropdownMenuItem(
value: bergerie,
child: Text(
bergerie.nom),
),
)
.toList(),
onChanged:
(bergerie) {
setState(() {
_bergerieSelectionnee =
bergerie;
});
},
),

const SizedBox(height: 20),
  DropdownButtonFormField<TypePrestation>(
    value: _typePrestation,
    decoration: const InputDecoration(
      labelText: "Type de prestation",
      border: OutlineInputBorder(),
    ),
    items: TypePrestation.values
        .map(
          (type) => DropdownMenuItem(
        value: type,
        child: Text(type.name),
      ),
    )
        .toList(),
    onChanged: (value) {
      if (value == null) return;

      setState(() {
        _typePrestation = value;
      });
    },
  ),

  const SizedBox(height: 20),

  TextFormField(
    controller:
    _montantConseilleController,
    keyboardType:
    TextInputType.number,
    decoration:
    const InputDecoration(
      labelText:
      "Montant conseillé",
      border:
      OutlineInputBorder(),
      suffixText: "FCFA",
    ),
  ),

  const SizedBox(height: 20),

  TextFormField(
    controller:
    _montantFactureController,
    keyboardType:
    TextInputType.number,
    decoration:
    const InputDecoration(
      labelText:
      "Montant facturé",
      border:
      OutlineInputBorder(),
      suffixText: "FCFA",
    ),
    validator: (value) {
      if (value == null ||
          value.trim().isEmpty) {
        return "Champ obligatoire";
      }
      return null;
    },
  ),

  const SizedBox(height: 20),

  TextFormField(
    controller:
    _montantPayeController,
    keyboardType:
    TextInputType.number,
    decoration:
    const InputDecoration(
      labelText:
      "Montant payé",
      border:
      OutlineInputBorder(),
      suffixText: "FCFA",
    ),
    validator: (value) {
      if (value == null ||
          value.trim().isEmpty) {
        return "Champ obligatoire";
      }
      return null;
    },
  ),

  const SizedBox(height: 20),

  DropdownButtonFormField<
      ModePaiement>(
    value: _modePaiement,
    decoration:
    const InputDecoration(
      labelText:
      "Mode de paiement",
      border:
      OutlineInputBorder(),
    ),
    items: ModePaiement.values
        .map(
          (mode) =>
          DropdownMenuItem(
            value: mode,
            child:
            Text(mode.name),
          ),
    )
        .toList(),
    onChanged: (value) {
      if (value == null) return;

      setState(() {
        _modePaiement =
            value;
      });
    },
  ),

  const SizedBox(height: 20),

  TextFormField(
    controller:
    _referenceController,
    decoration:
    const InputDecoration(
      labelText: "Référence",
      border:
      OutlineInputBorder(),
    ),
  ),

  const SizedBox(height: 20),

  TextFormField(
    controller:
    _motifRemiseController,
    maxLines: 2,
    decoration:
    const InputDecoration(
      labelText:
      "Motif de remise",
      border:
      OutlineInputBorder(),
    ),
  ),

  const SizedBox(height: 20),

  TextFormField(
    controller:
    _observationsController,
    maxLines: 4,
    decoration:
    const InputDecoration(
      labelText:
      "Observations",
      border:
      OutlineInputBorder(),
      alignLabelWithHint:
      true,
    ),
  ),

  const SizedBox(height: 20),

  TextFormField(
    controller:
    _dateController,
    readOnly: true,
    decoration:
    InputDecoration(
      labelText:
      "Date du paiement",
      border:
      const OutlineInputBorder(),
      suffixIcon:
      IconButton(
        icon: const Icon(
          Icons.calendar_month,
        ),
        onPressed:
        _selectionnerDate,
      ),
    ),
  ),

  const SizedBox(height: 30),

  Row(
    children: [
      Expanded(
        child:
        OutlinedButton.icon(
          onPressed:
          _enregistrement
              ? null
              : () =>
              Navigator.pop(
                context,
              ),
          icon: const Icon(
            Icons.arrow_back,
          ),
          label:
          const Text(
            "Retour",
          ),
        ),
      ),

      const SizedBox(
        width: 16,
      ),

      Expanded(
        child:
        ElevatedButton.icon(
          onPressed:
          _enregistrement
              ? null
              : _enregistrer,
          icon:
          _enregistrement
              ? const SizedBox(
            width:
            18,
            height:
            18,
            child:
            CircularProgressIndicator(
              strokeWidth:
              2,
            ),
          )
              : const Icon(
            Icons.save,
          ),
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