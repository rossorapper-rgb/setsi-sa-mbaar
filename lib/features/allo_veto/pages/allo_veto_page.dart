import 'package:flutter/material.dart';

import '../models/veterinaire_model.dart';
import '../repository/firebase_veterinaire_repository.dart';
import '../widgets/veterinaire_card.dart';

class AlloVetoPage extends StatefulWidget {
  const AlloVetoPage({super.key});

  @override
  State<AlloVetoPage> createState() => _AlloVetoPageState();
}

class _AlloVetoPageState extends State<AlloVetoPage> {
  final FirebaseVeterinaireRepository _repository =
  FirebaseVeterinaireRepository();

  final TextEditingController _searchController =
  TextEditingController();

  bool _loading = true;

  List<VeterinaireModel> _veterinaires = [];
  List<VeterinaireModel> _resultat = [];

  @override
  void initState() {
    super.initState();
    _charger();

    _searchController.addListener(
      _filtrerVeterinaires,
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(
      _filtrerVeterinaires,
    );

    _searchController.dispose();

    super.dispose();
  }

  Future<void> _charger() async {
    setState(() {
      _loading = true;
    });

    final veterinaires =
    await _repository.getVeterinairesDisponibles();

    if (!mounted) return;

    setState(() {
      _veterinaires = veterinaires;
      _resultat = List.from(veterinaires);
      _loading = false;
    });
  }

  void _filtrerVeterinaires() {
    final recherche =
    _searchController.text
        .trim()
        .toLowerCase();

    setState(() {
      if (recherche.isEmpty) {
        _resultat = List.from(_veterinaires);
        return;
      }

      _resultat = _veterinaires.where((v) {
        return v.nom
            .toLowerCase()
            .contains(recherche) ||
            v.region
                .toLowerCase()
                .contains(recherche) ||
            v.telephone
                .contains(recherche);
      }).toList();
    });
  }

  void _appeler(
      VeterinaireModel veterinaire,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Appelez le ${veterinaire.nom} au ${veterinaire.telephone}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🆘 Allo Véto"),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _charger,
        child: ListView(
          padding:
          const EdgeInsets.all(20),
          children: [

            Container(
              padding:
              const EdgeInsets.all(
                  16),
              decoration: BoxDecoration(
                color: Colors.orange
                    .withValues(
                    alpha: .12),
                borderRadius:
                BorderRadius
                    .circular(16),
              ),
              child: const Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [

                  Text(
                    "🚨 En cas d'urgence",
                    style: TextStyle(
                      fontWeight:
                      FontWeight
                          .bold,
                      fontSize: 18,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "• Isolez le mouton malade.\n"
                        "• Gardez de l'eau propre à disposition.\n"
                        "• Contactez immédiatement un vétérinaire partenaire.",
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            TextField(
              controller:
              _searchController,
              decoration:
              const InputDecoration(
                prefixIcon:
                Icon(Icons.search),
                hintText:
                "Rechercher un vétérinaire",
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            if (_resultat.isEmpty)

              const Center(
                child: Padding(
                  padding:
                  EdgeInsets.all(
                      40),
                  child: Text(
                    "Aucun vétérinaire trouvé.",
                  ),
                ),
              )

            else

              ..._resultat.map(
                    (veterinaire) =>
                    VeterinaireCard(
                      veterinaire:
                      veterinaire,
                      onCall: () =>
                          _appeler(
                            veterinaire,
                          ),
                    ),
              ),
          ],
        ),
      ),
    );
  }
}