import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/mouton_model.dart';
import '../models/reproduction_model.dart';
import '../providers/reproduction_provider.dart';
import 'reproduction_form.dart';

class MoutonReproductionTab extends ConsumerWidget {
final MoutonModel mouton;

const MoutonReproductionTab({
super.key,
required this.mouton,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
final reproductionEnCours = ref.watch(
reproductionEnCoursProvider(mouton.id),
);

final historique = ref.watch(
reproductionsProvider(mouton.id),
);

final format = DateFormat("dd/MM/yyyy");

return RefreshIndicator(
onRefresh: () async {
ref.invalidate(
reproductionEnCoursProvider(
mouton.id,
),
);

ref.invalidate(
reproductionsProvider(
mouton.id,
),
);
},
child: ListView(
padding: const EdgeInsets.all(16),
children: [

reproductionEnCours.when(

data: (reproduction) {

if (reproduction == null) {

return Card(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
children: [

const Icon(
Icons.favorite_border,
size: 70,
color: Colors.grey,
),

const SizedBox(height: 15),

const Text(
"Aucune reproduction en cours",
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

FilledButton.icon(
icon: const Icon(Icons.add),

label: const Text(
"Nouvelle reproduction",
),

onPressed: () {

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
Scaffold(
appBar: AppBar(
title: const Text(
"Nouvelle reproduction",
),
),
body: ReproductionForm(
mouton: mouton,
),
),
),
);
},
),
],
),
),
);
}

return _ReproductionEnCoursCard(
reproduction: reproduction,
format: format,
);
},

loading: () => const Card(
child: Padding(
padding: EdgeInsets.all(30),
child: Center(
child:
CircularProgressIndicator(),
),
),
),

error: (e, _) => Card(
child: Padding(
padding:
const EdgeInsets.all(20),
child: Text(
e.toString(),
),
),
),
),

const SizedBox(height: 20),

const Text(
"Historique",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),
  historique.when(

    data: (liste) {

      if (liste.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                "Aucun historique de reproduction.",
              ),
            ),
          ),
        );
      }

      return Column(
        children: liste.map((reproduction) {

          Color couleur;

          IconData icone;

          switch (reproduction.statut) {
            case ReproductionStatut.saillie:
              couleur = Colors.orange;
              icone = Icons.favorite;
              break;

            case ReproductionStatut.gestation:
              couleur = Colors.blue;
              icone = Icons.monitor_heart;
              break;

            case ReproductionStatut.miseBas:
              couleur = Colors.deepPurple;
              icone = Icons.child_care;
              break;

            case ReproductionStatut.terminee:
              couleur = Colors.green;
              icone = Icons.check_circle;
              break;
          }

          return Card(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                couleur.withOpacity(.15),
                child: Icon(
                  icone,
                  color: couleur,
                ),
              ),

              title: Text(
                reproduction.code,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 4),

                  Text(
                    "🐏 ${reproduction.nomBelier}",
                  ),

                  Text(
                    "📅 ${format.format(reproduction.dateSaillie)}",
                  ),

                  Text(
                    "🍼 ${format.format(reproduction.datePrevueMiseBas)}",
                  ),
                ],
              ),

              trailing: Chip(
                label: Text(
                  reproduction.statut.name
                      .toUpperCase(),
                ),
                backgroundColor:
                couleur.withOpacity(.15),
              ),
            ),
          );

        }).toList(),
      );
    },

    loading: () => const Center(
      child:
      CircularProgressIndicator(),
    ),

    error: (e, _) => Card(
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Text(
          e.toString(),
        ),
      ),
    ),
  ),
],
),
);
}
}

class _ReproductionEnCoursCard
    extends StatelessWidget {

final ReproductionModel reproduction;

final DateFormat format;

const _ReproductionEnCoursCard({
required this.reproduction,
required this.format,
});

@override
Widget build(BuildContext context) {

final progression =
reproduction.progression;

final joursRestants =
reproduction.joursRestants;
return Card(
elevation: 1,
child: Padding(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

Row(
children: [

const Icon(
Icons.favorite,
color: Colors.red,
),

const SizedBox(width: 8),

Expanded(
child: Text(
reproduction.code,
style: const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),
),

Chip(
label: Text(
reproduction.statut.name
.toUpperCase(),
),
),
],
),

const Divider(height: 30),

_ligne(
"🐏 Bélier",
reproduction.nomBelier,
),

_ligne(
"Race",
reproduction.raceBelier,
),

_ligne(
"Saillie",
format.format(
reproduction.dateSaillie,
),
),

_ligne(
"Mise bas prévue",
format.format(
reproduction
.datePrevueMiseBas,
),
),

const SizedBox(height: 20),

Text(
"Progression de la gestation",
style: Theme.of(context)
.textTheme
.titleMedium,
),

const SizedBox(height: 10),

LinearProgressIndicator(
value: progression,
minHeight: 10,
borderRadius:
BorderRadius.circular(10),
),

const SizedBox(height: 10),

Align(
alignment:
Alignment.centerRight,
child: Text(
"${(progression * 100).toStringAsFixed(0)} %",
style: const TextStyle(
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(height: 15),

Card(
color: Colors.orange.shade50,
child: Padding(
padding:
const EdgeInsets.all(12),
child: Row(
children: [

const Icon(
Icons.schedule,
color: Colors.orange,
),

const SizedBox(width: 10),

Expanded(
child: Text(
joursRestants > 0
? "$joursRestants jours restants avant la mise bas."
: "La mise bas est attendue.",
),
),
],
),
),
),

if (reproduction
.observations
.isNotEmpty) ...[

const SizedBox(height: 20),

Text(
"Observations",
style: Theme.of(context)
.textTheme
.titleMedium,
),

const SizedBox(height: 8),

Text(
reproduction.observations,
),
],

const SizedBox(height: 25),

SizedBox(
width: double.infinity,
child: FilledButton.icon(
icon: const Icon(
Icons.child_care,
),
label: const Text(
"ENREGISTRER LA MISE BAS",
),
onPressed: () {
// Le formulaire de mise bas
// sera développé ensuite.
},
),
),
],
),
),
);
}

Widget _ligne(
String titre,
String valeur,
) {
return Padding(
padding:
const EdgeInsets.symmetric(
vertical: 5,
),
child: Row(
children: [

SizedBox(
width: 140,
child: Text(
titre,
style: const TextStyle(
fontWeight:
FontWeight.bold,
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
}