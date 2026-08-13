import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/current_user_service.dart';

import '../../clients/repositories/firebase_client_repository.dart';

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

  const GestationsPage({
    super.key,
    this.bergerie,
  });

  @override
  State<GestationsPage> createState() =>
      _GestationsPageState();
}

class _GestationsPageState extends State<GestationsPage> {
  final FirebaseGestationRepository _repository =
  FirebaseGestationRepository();

  final FirebaseMoutonRepository _moutonRepository =
  FirebaseMoutonRepository();

  final FirebaseClientRepository _clientRepository =
  FirebaseClientRepository();

  bool _loading = true;

  List<GestationModel> _gestations = [];

  List<MoutonModel> _moutons = [];

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final session = CurrentUserService.instance;

      List<GestationModel> gestations = [];
      List<MoutonModel> moutons = [];

      // ==========================================================
      // BERGERIE EXPLICITEMENT SÉLECTIONNÉE
      // ==========================================================

      if (widget.bergerie != null) {
        gestations =
        await _repository.getGestationsParBergerie(
          widget.bergerie!.id,
        );

        final tousLesMoutons =
        await _moutonRepository.getMoutons();

        moutons = tousLesMoutons
            .where(
              (mouton) =>
          mouton.bergerieId ==
              widget.bergerie!.id,
        )
            .toList();
      }

      // ==========================================================
      // CLIENT CONNECTÉ
      // ==========================================================
      //
      // Une gestation appartient d'abord à une femelle du client.
      // La bergerie est facultative. Le client doit donc pouvoir
      // retrouver ses gestations même lorsqu'il n'a aucune bergerie.
      // ==========================================================

      else if (session.isClient) {
        final utilisateur = session.currentUser;

        if (utilisateur == null) {
          throw Exception("Utilisateur connecté introuvable.");
        }

        // ----------------------------------------------------------
        // Retrouver précisément la fiche Client du compte connecté.
        // On ne prend surtout pas le premier client de la collection.
        // ----------------------------------------------------------
        final clients = await _clientRepository.getClients();

        final client = clients.firstWhere(
              (client) =>
          client.telephone.trim() ==
              utilisateur.telephone.trim(),
          orElse: () => throw Exception(
            "Fiche client introuvable pour ce compte.",
          ),
        );

        // ----------------------------------------------------------
        // Le mouton appartient au client.
        // La bergerie est facultative.
        // ----------------------------------------------------------
        final tousLesMoutons =
        await _moutonRepository.getMoutonsByClient(
          client.id,
        );

        final idsMoutonsClient =
        tousLesMoutons.map((mouton) => mouton.id).toSet();

        // ----------------------------------------------------------
        // Les gestations sont rattachées à la femelle (brebisId).
        // On filtre donc toutes les gestations avec les femelles
        // appartenant à ce client.
        // ----------------------------------------------------------
        final toutesLesGestations =
        await _repository.getGestations();

        gestations = toutesLesGestations
            .where(
              (gestation) =>
              idsMoutonsClient.contains(
                gestation.brebisId,
              ),
        )
            .toList();

        moutons = tousLesMoutons;

        // Si la page est ouverte depuis une bergerie précise,
        // on limite uniquement les moutons affichés à cette
        // bergerie. La gestation reste liée au client/femelle.
        if (widget.bergerie != null) {
          moutons = tousLesMoutons
              .where(
                (mouton) =>
            mouton.bergerieId ==
                widget.bergerie!.id,
          )
              .toList();
        }
      }

      // ==========================================================
      // ADMIN / RESPONSABLE / TECHNICIEN
      // ==========================================================

      else {
        gestations =
        await _repository.getGestations();

        moutons =
        await _moutonRepository.getMoutons();
      }

      // Évite les doublons éventuels.
      final gestationsUniques = <String, GestationModel>{};

      for (final gestation in gestations) {
        gestationsUniques[gestation.id] = gestation;
      }

      final listeFinale =
      gestationsUniques.values.toList();

      listeFinale.sort(
            (a, b) =>
            b.dateCreation.compareTo(
              a.dateCreation,
            ),
      );

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
          content: Text(
            "Impossible de charger les gestations : $e",
          ),
        ),
      );
    }
  }

  Future<void> _nouvelleGestation() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddGestationPage(
          bergerie: widget.bergerie,
        ),
      ),
    );

    if (result == true) {
      _charger();
    }
  }

  Future<void> _ouvrirDetails(
      GestationModel gestation,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GestationDetailsPage(
          gestation: gestation,
        ),
      ),
    );

    _charger();
  }

  Future<void> _modifier(
      GestationModel gestation,
      ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddGestationPage(
          gestation: gestation,
        ),
      ),
    );

    if (result == true) {
      _charger();
    }
  }

  Future<void> _miseBas(
      GestationModel gestation,
      ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MiseBasPage(
          gestation: gestation,
        ),
      ),
    );

    if (result == true) {
      _charger();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = CurrentUserService.instance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Retour",
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/dashboard/admin');
            }
          },
        ),
        title: Text(
          widget.bergerie == null
              ? "Gestion des gestations"
              : "Gestations - ${widget.bergerie!.nom}",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _charger,
          ),
        ],
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _charger,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            LayoutBuilder(
              builder:
                  (context, constraints) {
                return Wrap(
                  alignment:
                  WrapAlignment.spaceBetween,
                  crossAxisAlignment:
                  WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width:
                      constraints.maxWidth >
                          500
                          ? constraints.maxWidth -
                          220
                          : constraints.maxWidth,
                      child: const Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gestations",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Suivi des femelles gestantes",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ------------------------------------------------
                    // Le Client conserve la possibilité
                    // d'enregistrer une nouvelle gestation.
                    // ------------------------------------------------

                    if (session.isClient ||
                        session.isAdmin ||
                        session.isResponsable)
                      ElevatedButton.icon(
                        onPressed:
                        _nouvelleGestation,
                        icon:
                        const Icon(Icons.add),
                        label: const Text(
                          "Nouvelle gestation",
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            if (session.isClient &&
                _gestations.isEmpty)
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 30,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.pets_outlined,
                      size: 64,
                      color:
                      Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Aucune gestation enregistrée",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Vos gestations apparaîtront "
                          "ici dès qu'elles seront enregistrées.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                        Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              GestationDashboard(
                gestations: _gestations,
                moutons: _moutons,
                onVoirToutes: () {},
                onOuvrirFiche:
                _ouvrirDetails,
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