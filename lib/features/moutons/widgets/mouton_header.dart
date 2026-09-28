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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                  maxHeight: 450,
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image(
                      image: imageProvider,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.pets,
                          size: 72,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              mouton.nom.isEmpty
                  ? "Sans nom"
                  : mouton.nom,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: mouton.actif
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                mouton.actif
                    ? "ACTIF"
                    : "ARCHIVÉ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
}
