import 'package:flutter/material.dart';

import '../../../core/widgets/app_action_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';

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
  final FirebaseMoutonRepository _repository = FirebaseMoutonRepository();
  final TextEditingController _searchController = TextEditingController();

  // Cache mémoire par bergerie : les moutons déjà chargés réapparaissent
  // immédiatement lors du retour sur la page.
  static final Map<String, List<MoutonModel>> _cacheParBergerie = {};

  late Future<List<MoutonModel>> _futureMoutons;

  List<MoutonModel> _moutons = [];
  List<MoutonModel> _moutonsFiltres = [];

  @override
  void initState() {
    super.initState();

    final cache = _cacheParBergerie[widget.bergerie.id];

    if (cache != null) {
      _moutons = List<MoutonModel>.from(cache);
      _moutonsFiltres = List<MoutonModel>.from(cache);
      _futureMoutons = Future.value(_moutons);

      // Actualisation en arrière-plan : l'utilisateur ne reste pas bloqué
      // pendant la nouvelle lecture Firestore.
      _actualiserEnArrierePlan();
    } else {
      _futureMoutons = _chargerMoutons();
    }

    _searchController.addListener(_filtrerMoutons);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrerMoutons);
    _searchController.dispose();
    super.dispose();
  }

  Future<List<MoutonModel>> _chargerMoutons() async {
    final moutons = await _repository.getMoutonsByBergerie(widget.bergerie.id);

    _cacheParBergerie[widget.bergerie.id] = List<MoutonModel>.from(moutons);

    return moutons;
  }

  Future<void> _actualiserEnArrierePlan() async {
    try {
      final moutons = await _chargerMoutons();

      if (!mounted) return;

      setState(() {
        _moutons = moutons;
        _filtrerMoutonsSansSetState();
      });
    } catch (_) {
      // Le cache reste affiché si l'actualisation réseau échoue.
    }
  }

  void _filtrerMoutonsSansSetState() {
    final recherche = _searchController.text.trim().toLowerCase();

    if (recherche.isEmpty) {
      _moutonsFiltres = List.from(_moutons);
      return;
    }

    _moutonsFiltres = _moutons.where((mouton) {
      return mouton.nom.toLowerCase().contains(recherche) ||
          mouton.numeroIdentification.toLowerCase().contains(recherche) ||
          mouton.race.toLowerCase().contains(recherche);
    }).toList();
  }

  void _filtrerMoutons() {
    setState(_filtrerMoutonsSansSetState);
  }

  Future<void> _ajouterMouton() async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMoutonPage(bergerie: widget.bergerie),
      ),
    );

    if (!mounted) return;

    if (resultat == true) {
      _cacheParBergerie.remove(widget.bergerie.id);
      setState(() {
        _futureMoutons = _chargerMoutons();
      });
    }
  }

  Future<void> _ouvrirDetails(MoutonModel mouton) async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoutonDetailsPage(
            mouton: mouton,
            bergerie: widget.bergerie,
          ),
      ),
    );

    if (!mounted) return;

    if (resultat == true) {
      _cacheParBergerie.remove(widget.bergerie.id);
      setState(() {
        _futureMoutons = _chargerMoutons();
      });
    }
  }

  Future<void> _rafraichir() async {
    try {
      final moutons = await _chargerMoutons();

      if (!mounted) return;

      setState(() {
        _moutons = moutons;
        _filtrerMoutonsSansSetState();
        _futureMoutons = Future.value(moutons);
      });
    } catch (_) {
      // Le FutureBuilder conserve les données déjà affichées.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Moutons - ${widget.bergerie.nom}"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<MoutonModel>>(
        future: _futureMoutons,
        builder: (context, snapshot) {
          // Si le cache est disponible, on affiche immédiatement les données
          // déjà connues, même pendant une actualisation réseau.
          final donnees = snapshot.data ?? _moutons;

          if (snapshot.connectionState == ConnectionState.waiting &&
              donnees.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && donnees.isEmpty) {
            return Center(
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 70),
                      const SizedBox(height: 20),
                      const Text(
                        "Une erreur est survenue",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(snapshot.error.toString(), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            );
          }

          if (snapshot.hasData && !identical(snapshot.data, _moutons)) {
            _moutons = snapshot.data!;
            _moutonsFiltres = List.from(_moutons);

            if (_searchController.text.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _filtrerMoutonsSansSetState();
              });
            }
          }

          final total = _moutons.length;
          final beliers = _moutons.where((m) {
            final sexe = m.sexe.toLowerCase();
            return sexe == "male" || sexe == "mâle";
          }).length;
          final brebis = total - beliers;

          return RefreshIndicator(
            onRefresh: _rafraichir,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.bergerie.nom,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.bergerie.id,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _StatItem(titre: "Moutons", valeur: "$total", icon: Icons.pets)),
                          const SizedBox(width: 12),
                          Expanded(child: _StatItem(titre: "Béliers", valeur: "$beliers", icon: Icons.male)),
                          const SizedBox(width: 12),
                          Expanded(child: _StatItem(titre: "Brebis", valeur: "$brebis", icon: Icons.female)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _searchController,
                  icon: Icons.search,
                  label: "Recherche",
                ),
                const SizedBox(height: 20),
                AppActionButton(
                  icon: Icons.add,
                  label: "Ajouter un mouton",
                  onPressed: _ajouterMouton,
                ),
                const SizedBox(height: 24),
                if (_moutonsFiltres.isEmpty)
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Column(
                        children: const [
                          Icon(Icons.pets, size: 80, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            "Aucun mouton trouvé",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Ajoutez un mouton ou modifiez votre recherche.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._moutonsFiltres.map(
                    (mouton) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MoutonCard(
                        mouton: mouton,
                        onTap: () => _ouvrirDetails(mouton),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icon;

  const _StatItem({
    required this.titre,
    required this.valeur,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: primary.withValues(alpha: 0.12),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(height: 12),
          Text(
            valeur,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            titre,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
