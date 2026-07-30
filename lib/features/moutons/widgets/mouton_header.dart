import 'package:flutter/material.dart';

import '../models/mouton_model.dart';

class MoutonHeader extends StatelessWidget {
final MoutonModel mouton;

const MoutonHeader({
super.key,
required this.mouton,
});

@override
Widget build(BuildContext context) {
final ImageProvider imageProvider =
mouton.photoUrl.isNotEmpty
? NetworkImage(mouton.photoUrl)
: const AssetImage(
"assets/images/sheep_placeholder.png",
);

return Card(
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(20),
),
child: Padding(
padding:
const EdgeInsets.all(20),
child: Column(
children: [
CircleAvatar(
radius: 65,
backgroundImage:
imageProvider,
),

const SizedBox(height: 18),

Text(
mouton.nom.isEmpty
? "Sans nom"
: mouton.nom,
textAlign:
TextAlign.center,
style: const TextStyle(
fontSize: 26,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 10),

Wrap(
spacing: 8,
runSpacing: 8,
alignment:
WrapAlignment.center,
children: [
_chip(
icon: Icons.qr_code,
text: mouton
.numeroIdentification,
color: Colors.blue,
),

_chip(
icon: Icons.pets,
text: mouton.race,
color:
Colors.orange,
),

_chip(
icon:
mouton.sexe ==
"Mâle"
? Icons.male
: Icons.female,
text: mouton.sexe,
color:
Colors.purple,
),
],
),

const SizedBox(height: 18),
  Container(
    padding:
    const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: mouton.actif
          ? Colors.green.shade100
          : Colors.red.shade100,
      borderRadius:
      BorderRadius.circular(
        30,
      ),
    ),
    child: Text(
      mouton.actif
          ? "ACTIF"
          : "ARCHIVÉ",
      style: TextStyle(
        fontWeight:
        FontWeight.bold,
        color: mouton.actif
            ? Colors.green.shade800
            : Colors.red.shade800,
      ),
    ),
  ),
],
),
),
);
}

Widget _chip({
  required IconData icon,
  required String text,
  required Color color,
}) {
  return Chip(
    avatar: Icon(
      icon,
      color: color,
      size: 18,
    ),
    label: Text(text),
  );
}
}