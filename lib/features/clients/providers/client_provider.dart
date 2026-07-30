import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client_model.dart';

final clientProvider = Provider<List<ClientModel>>((ref) {
  return const [
    ClientModel(
      id: "CL001",
      nom: "Mamadou Ndiaye",
      telephone: "77 123 45 67",
      quartier: "Grand Yoff",
      adresse: "Grand Yoff Arafat",
      nombreTroupeaux: 2,
      nombreMoutons: 18,
      abonnement: "Prestige",
      actif: true,
    ),
    ClientModel(
      id: "CL002",
      nom: "Ousmane Ba",
      telephone: "76 456 78 90",
      quartier: "Yoff",
      adresse: "Yoff Tonghor",
      nombreTroupeaux: 1,
      nombreMoutons: 7,
      abonnement: "Confort",
      actif: true,
    ),
  ];
});