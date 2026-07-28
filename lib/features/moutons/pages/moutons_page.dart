import 'package:flutter/material.dart';

import '../../bergeries/models/bergerie_model.dart';
import '../models/mouton_model.dart';
import '../repository/firebase_mouton_repository.dart';
import '../widgets/mouton_card.dart';
import 'add_mouton_page.dart';
import 'mouton_details_page.dart';

class MoutonsPage extends StatefulWidget {
  final BergerieModel bergerie;

  const MoutonsPage({
    super.key,
    required this.bergerie,
  });

  @override
  State<MoutonsPage> createState() => _MoutonsPageState();
}

class _MoutonsPageState extends State<MoutonsPage> {
  final FirebaseMoutonRepository _repository =
  FirebaseMoutonRepository();

  late Future<List<MoutonModel>> _futureMoutons;

  @override
  void initState() {
    super.initState();
    _chargerMoutons();
  }

  void _chargerMoutons() {
    _futureMoutons = _repository.getMoutonsByBergerie(
      widget.bergerie.id,
    );
  }

  Future<void> _ajouterMouton() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMoutonPage(
          bergerie: widget.bergerie,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _chargerMoutons();
      });
    }
  }

  Future<void> _rafraichir() async {
    setState(() {
      _chargerMoutons();
    });

    await _futureMoutons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Moutons - ${widget.bergerie.nom}",
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterMouton,
        icon: const Icon(Icons.add),
        label: const Text("Ajouter"),
      ),
      body: RefreshIndicator(
        onRefresh: _rafraichir,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher un mouton...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: FutureBuilder<List<MoutonModel>>(
                  future: _futureMoutons,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Erreur : ${snapshot.error}",
                        ),
                      );
                    }

                    final moutons = snapshot.data ?? [];

                    if (moutons.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 120),

                          Icon(
                            Icons.pets,
                            size: 90,
                            color: Colors.grey,
                          ),

                          SizedBox(height: 20),

                          Center(
                            child: Text(
                              "Aucun mouton enregistré",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(height: 10),

                          Center(
                            child: Text(
                              "Appuyez sur Ajouter pour créer votre premier mouton.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      itemCount: moutons.length,
                      itemBuilder: (context, index) {
                        final mouton = moutons[index];

                        return MoutonCard(
                          mouton: mouton,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MoutonDetailsPage(
                                  mouton: mouton,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}