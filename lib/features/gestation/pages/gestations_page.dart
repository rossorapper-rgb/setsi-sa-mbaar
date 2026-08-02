import 'package:flutter/material.dart';

import '../../moutons/models/mouton_model.dart';
import '../../moutons/repository/firebase_mouton_repository.dart';

import '../models/gestation_model.dart';
import '../repositories/firebase_gestation_repository.dart';
import '../widgets/gestation_dashboard.dart';

import 'add_gestation_page.dart';
import 'gestation_details_page.dart';
import 'mise_bas_page.dart';
import '../../bergeries/models/bergerie_model.dart';

class GestationsPage extends StatefulWidget {
  final BergerieModel? bergerie;

  const GestationsPage({
    super.key,
    this.bergerie,
  });

  @override
  State<GestationsPage> createState() =>
      _GestationsPageState();
}
class _GestationsPageState
    extends State<GestationsPage> {
final FirebaseGestationRepository _repository =
FirebaseGestationRepository();

final FirebaseMoutonRepository _moutonRepository =
FirebaseMoutonRepository();

bool _loading = true;

List<GestationModel> _gestations = [];

List<MoutonModel> _moutons = [];

@override
void initState() {
super.initState();
_charger();
}

Future<void> _charger() async {
setState(() {
_loading = true;
});

final gestations =
widget.bergerie == null
    ? await _repository.getGestations()
    : await _repository.getGestationsParBergerie(
  widget.bergerie!.id,
);
final moutons = await _moutonRepository.getMoutons();

if (!mounted) return;

setState(() {
_gestations = gestations;
_moutons = moutons;
_loading = false;
});
}

Future<void> _nouvelleGestation() async {
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => AddGestationPage(
        bergerie: widget.bergerie,
      ),
    ),
  );

  if (result == true) {
    _charger();
  }
}

Future<void> _ouvrirDetails(
GestationModel gestation,
) async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => GestationDetailsPage(
gestation: gestation,
),
),
);

_charger();
}

Future<void> _modifier(
GestationModel gestation,
) async {
final result = await Navigator.push<bool>(
context,
MaterialPageRoute(
builder: (_) => AddGestationPage(
gestation: gestation,
),
),
);

if (result == true) {
_charger();
}
}

Future<void> _miseBas(
GestationModel gestation,
) async {
final result = await Navigator.push<bool>(
context,
MaterialPageRoute(
builder: (_) => MiseBasPage(
gestation: gestation,
),
),
);

if (result == true) {
_charger();
}
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
  title: Text(
    widget.bergerie == null
        ? "Gestion des gestations"
        : "Gestations - ${widget.bergerie!.nom}",
  ),
actions: [
IconButton(
icon: const Icon(Icons.refresh),
onPressed: _charger,
),
],
),
body: _loading
? const Center(
child: CircularProgressIndicator(),
)
: RefreshIndicator(
onRefresh: _charger,
child: ListView(
physics: const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.all(20),
children: [
LayoutBuilder(
  builder: (context, constraints) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: constraints.maxWidth > 500
              ? constraints.maxWidth - 220
              : constraints.maxWidth,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Gestations",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Suivi des femelles gestantes",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _nouvelleGestation,
          icon: const Icon(Icons.add),
          label: const Text("Nouvelle gestation"),
        ),
      ],
    );
  },
),

const SizedBox(height: 24),
GestationDashboard(
gestations: _gestations,
moutons: _moutons,
onVoirToutes: () {},
onOuvrirFiche: _ouvrirDetails,
onModifier: _modifier,
onMiseBas: _miseBas,
),

const SizedBox(height: 20),
],
),
),
);
}
}