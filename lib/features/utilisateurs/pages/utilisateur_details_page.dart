import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../models/user_role.dart';

import '../providers/utilisateur_provider.dart';

class UtilisateurDetailsPage extends ConsumerWidget {
final String utilisateurId;

const UtilisateurDetailsPage({
super.key,
required this.utilisateurId,
});

@override
Widget build(BuildContext context, WidgetRef ref) {

final utilisateurAsync =
ref.watch(
utilisateurProvider(utilisateurId),
);

return ResponsivePage(
title: "Détails utilisateur",

child: utilisateurAsync.when(

loading: () => const Center(
child: CircularProgressIndicator(),
),

error: (error, stack) {
return Center(
child: Text(
error.toString(),
),
);
},

data: (utilisateur) {

if (utilisateur == null) {
return const Center(
child: Text(
"Utilisateur introuvable.",
),
);
}

return ListView(
padding:
const EdgeInsets.all(20),

children: [

AppCard(

child: Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Row(

children: [

CircleAvatar(
radius: 35,
child: Text(
utilisateur.prenom
.isNotEmpty
? utilisateur
.prenom[0]
.toUpperCase()
: "?",
),
),

const SizedBox(
width: 20,
),

Expanded(

child: Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Text(
utilisateur.nomComplet,
style:
const TextStyle(
fontSize: 22,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 6),

Text(
utilisateur.role.label,
),
const SizedBox(height: 20),

_infoTile(
"Téléphone",
utilisateur.telephone,
Icons.phone,
),

_infoTile(
"Email technique",
utilisateur.emailTechnique,
Icons.email,
),

_infoTile(
"Statut",
utilisateur.statut,
Icons.verified_user,
),

_infoTile(
"Bergerie",
utilisateur.bergerieId ??
"Non affectée",
Icons.home_work,
),

_infoTile(
"Créé par",
utilisateur.creePar,
Icons.person_outline,
),
],
),
),
],
),
],
),
),

const SizedBox(height: 20),

Row(
children: [

Expanded(
child: ElevatedButton.icon(
onPressed: () {
context.push(
'/utilisateurs/edit/$utilisateurId',
);
},
icon: const Icon(Icons.edit),
label: const Text("Modifier"),
),
),

const SizedBox(width: 16),

Expanded(
child: ElevatedButton.icon(
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
foregroundColor: Colors.white,
),
onPressed: () async {

final repository =
ref.read(
utilisateurRepositoryProvider,
);

await repository
.deleteUtilisateur(
utilisateur.id,
);

if (!context.mounted) return;

Navigator.pop(context);
},
icon: const Icon(Icons.delete),
label: const Text("Désactiver"),
),
),
],
),
],
);
},
),
);
}

Widget _infoTile(
    String titre,
    String valeur,
    IconData icon,
    ) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 8,
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey,
        ),
        const SizedBox(width: 12),
        Text(
          "$titre : ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
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