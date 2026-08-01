import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardDrawer extends StatelessWidget {
const DashboardDrawer({
super.key,
required this.selectedIndex,
});

final int selectedIndex;

static const List<_DrawerItem> _items = [
_DrawerItem(
icon: Icons.dashboard,
title: "Tableau de bord",
),
_DrawerItem(
icon: Icons.people,
title: "Clients",
),
_DrawerItem(
icon: Icons.home_work,
title: "Bergeries",
),
_DrawerItem(
icon: Icons.pets,
title: "Moutons",
),
_DrawerItem(
icon: Icons.pregnant_woman,
title: "Gestations",
),
_DrawerItem(
icon: Icons.cleaning_services,
title: "Interventions",
),
_DrawerItem(
icon: Icons.card_membership,
title: "Abonnements",
),
_DrawerItem(
icon: Icons.payments,
title: "Paiements",
),
_DrawerItem(
icon: Icons.bar_chart,
title: "Rapports",
),
_DrawerItem(
icon: Icons.settings,
title: "Paramètres",
),
];

@override
Widget build(BuildContext context) {
return Drawer(
child: SafeArea(
child: Column(
children: [
Container(
width: double.infinity,
padding: const EdgeInsets.all(24),
color: Theme.of(context).colorScheme.primary,
child: const Column(
children: [
CircleAvatar(
radius: 36,
child: Icon(
Icons.pets,
size: 36,
),
),
SizedBox(height: 12),
Text(
"SET'SI SA MBAAR",
style: TextStyle(
color: Colors.white,
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
],
),
),

Expanded(
child: ListView.builder(
itemCount: _items.length,
itemBuilder: (context, index) {
final item = _items[index];
return ListTile(
leading: Icon(item.icon),
title: Text(item.title),
selected: selectedIndex == index,
selectedTileColor: Theme.of(context)
.colorScheme
.primary
.withValues(alpha: 0.10),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10),
),
onTap: () {
switch (index) {
case 0:
context.go('/dashboard/admin');
break;

case 1:
context.go('/clients');
break;

case 2:
context.go('/bergeries');
break;

case 3:
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Veuillez d'abord ouvrir une bergerie pour accéder aux moutons.",
),
),
);
break;
case 4:
context.go('/gestations');
break;

case 5:
context.go('/interventions');
break;

case 6:
case 7:
case 8:
case 9:
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Ce module sera disponible prochainement.",
),
),
);
break;
}
},
);
},
),
),

const Divider(height: 1),

ListTile(
leading: const Icon(Icons.logout),
title: const Text("Déconnexion"),
onTap: () {
context.go('/login');
},
),
],
),
),
);
}
}
class _DrawerItem {
final IconData icon;
final String title;

const _DrawerItem({
required this.icon,
required this.title,
});
}