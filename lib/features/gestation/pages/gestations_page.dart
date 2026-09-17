import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/current_user_service.dart';
import '../../moutons/models/mouton_model.dart';
import '../../moutons/repository/firebase_mouton_repository.dart';
import '../../bergeries/models/bergerie_model.dart';
import '../models/gestation_model.dart';
import '../repositories/firebase_gestation_repository.dart';
import '../widgets/gestation_dashboard.dart';

import 'add_gestation_page.dart';
import 'gestation_details_page.dart';
import 'mise_bas_page.dart';

class GestationsPage extends StatefulWidget {
  final BergerieModel? bergerie;

  const GestationsPage({super.key, this.bergerie});

  @override
  State<GestationsPage> createState() => _GestationsPageState();
}

class _GestationsPageState extends State<GestationsPage> {
  final FirebaseGestationRepository _repository = FirebaseGestationRepository();
  final FirebaseMoutonRepository _moutonRepository = FirebaseMoutonRepository();

  bool _loading = true;
  List<GestationModel> _gestations = [];
  List<MoutonModel> _moutons = [];

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    if (mounted) setState(() => _loading = true);

    try {
      final session = CurrentUserService.instance;
      final bergerieIdSession = session.bergerieId?.trim();

      late final Future<List<GestationModel>> gestationsFuture;
      late final Future<List<MoutonModel>> moutonsFuture;

      if (widget.bergerie != null) {
        final bergerieId = widget.bergerie!.id;
        gestationsFuture = _repository.getGestationsParBergerie(bergerieId);
        moutonsFuture = _moutonRepository.getMoutonsByBergerie(bergerieId);
      } else if (session.isAdmin) {
        gestationsFuture = _repository.getGestations();
        moutonsFuture = _moutonRepository.getMoutons();
      } else {
        if (bergerieIdSession == null || bergerieIdSession.isEmpty) {
          throw Exception("Aucune bergerie n'est associée à votre compte.");
        }

        gestationsFuture =
            _repository.getGestationsParBergerie(bergerieIdSession);
        moutonsFuture =
            _moutonRepository.getMoutonsByBergerie(bergerieIdSession);
      }

      // Les deux requêtes partent en même temps : la page n'attend plus
      // la fin du chargement des gestations avant de charger les moutons.
      final results = await Future.wait<Object>([
        gestationsFuture,
        moutonsFuture,
      ]);

      final gestations = results[0] as List<GestationModel>;
      final moutons = results[1] as List<MoutonModel>;

      final gestationsUniques = <String, GestationModel>{};
      for (final gestation in gestations) {
        gestationsUniques[gestation.id] = gestation;
      }

      final listeFinale = gestationsUniques.values.toList();
      listeFinale.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));

      if (!mounted) return;

      setState(() {
        _gestations = listeFinale;
        _moutons = moutons;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _gestations = [];
        _moutons = [];
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Impossible de charger les gestations : $e'),
        ),
      );
    }
  }

  Future<void> _nouvelleGestation() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddGestationPage(bergerie: widget.bergerie),
      ),
    );
    if (result == true) _charger();
  }

  Future<void> _ouvrirDetails(GestationModel gestation) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GestationDetailsPage(gestation: gestation)),
    );
    _charger();
  }

  Future<void> _modifier(GestationModel gestation) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddGestationPage(gestation: gestation)),
    );
    if (result == true) _charger();
  }

  Future<void> _miseBas(GestationModel gestation) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MiseBasPage(gestation: gestation)),
    );
    if (result == true) _charger();
  }

  @override
  Widget build(BuildContext context) {
    final session = CurrentUserService.instance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/dashboard/bergerie');
            }
          },
        ),
        title: Text(
          widget.bergerie == null
              ? 'Gestion des gestations'
              : 'Gestations - ${widget.bergerie!.nom}',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _charger),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _charger,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: constraints.maxWidth > 500
                                ? constraints.maxWidth - 220
                                : constraints.maxWidth,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gestations',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Suivi des femelles gestantes',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          if (session.isClient ||
                              session.isAdmin ||
                              session.isResponsable)
                            SizedBox(
                              width: constraints.maxWidth > 500
                                  ? 220
                                  : constraints.maxWidth,
                              child: ElevatedButton.icon(
                                onPressed: _nouvelleGestation,
                                icon: const Icon(Icons.add),
                                label: const Text('Nouvelle gestation'),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_gestations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          'Aucune gestation enregistrée.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    GestationDashboard(
                      gestations: _gestations,
                      moutons: _moutons,
                      onVoirToutes: () {},
                      onOuvrirFiche: _ouvrirDetails,
                      onModifier: _modifier,
                      onMiseBas: _miseBas,
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
