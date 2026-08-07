import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/utilisateur_model.dart';
import '../models/user_role.dart';
import '../providers/utilisateur_provider.dart';

class UtilisateursPage extends ConsumerStatefulWidget {
  const UtilisateursPage({super.key});

  @override
  ConsumerState<UtilisateursPage> createState() =>
      _UtilisateursPageState();
}

class _UtilisateursPageState
    extends ConsumerState<UtilisateursPage> {

final TextEditingController _searchController =
TextEditingController();

String _search = "";

@override
void dispose() {
_searchController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {

final utilisateursAsync =
ref.watch(utilisateursStreamProvider);

return Scaffold(
appBar: AppBar(
title: const Text(
"Utilisateurs",
),
actions: [
IconButton(
icon: const Icon(Icons.refresh),
onPressed: () {
ref.invalidate(
utilisateursProvider,
);
},
),
],
),

floatingActionButton:
FloatingActionButton.extended(
onPressed: () {
context.push(
'/utilisateurs/add',
);
},
icon: const Icon(Icons.person_add),
label: const Text(
"Ajouter",
),
),

body: Column(
children: [

Padding(
padding: const EdgeInsets.all(16),
child: TextField(
controller: _searchController,
decoration: const InputDecoration(
hintText:
"Rechercher un utilisateur...",
prefixIcon:
Icon(Icons.search),
border:
OutlineInputBorder(),
),
onChanged: (value) {
setState(() {
_search = value;
});
},
),
),

Expanded(
child: utilisateursAsync.when(
data: (utilisateurs) {

final liste =
utilisateurs.where((u) {

if (_search.isEmpty) {
return true;
}

final texte =
_search.toLowerCase();

return u.nomComplet
.toLowerCase()
.contains(texte) ||
u.telephone
.contains(texte);

}).toList();
if (liste.isEmpty) {
return const Center(
child: Text(
"Aucun utilisateur trouvé.",
),
);
}

return ListView.separated(
padding: const EdgeInsets.all(16),
itemCount: liste.length,
separatorBuilder: (_, __) =>
const SizedBox(height: 12),
itemBuilder: (context, index) {
final UtilisateurModel utilisateur =
liste[index];

return Card(
elevation: 2,
child: ListTile(
leading: CircleAvatar(
child: Text(
utilisateur.prenom.isNotEmpty
? utilisateur.prenom[0]
.toUpperCase()
: "?",
),
),

title: Text(
utilisateur.nomComplet,
),

subtitle: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(utilisateur.telephone),
Text(
utilisateur.role.label,
),
],
),

trailing: const Icon(
Icons.arrow_forward_ios,
size: 18,
),

onTap: () {
context.push(
'/utilisateurs/details/${utilisateur.id}',
);
},
),
);
},
);
},

loading: () => const Center(
child: CircularProgressIndicator(),
),

error: (error, stack) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Text(
error.toString(),
textAlign: TextAlign.center,
),
),
);
},
),
),
],
),
);
}
}