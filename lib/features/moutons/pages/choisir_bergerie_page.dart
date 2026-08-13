import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/current_user_service.dart';
import '../../clients/repositories/firebase_client_repository.dart';
import '../../bergeries/models/bergerie_model.dart';
import '../../bergeries/repository/firebase_bergerie_repository.dart';

class ChoisirBergeriePage extends StatefulWidget {
  const ChoisirBergeriePage({super.key});

  @override
  State<ChoisirBergeriePage> createState() =>
      _ChoisirBergeriePageState();
}

class _ChoisirBergeriePageState
    extends State<ChoisirBergeriePage> {
  final FirebaseClientRepository _clientRepository =
  FirebaseClientRepository();

  final FirebaseBergerieRepository _bergerieRepository =
  FirebaseBergerieRepository();

  bool _loading = true;
  String? _erreur;

  List<BergerieModel> _bergeries = [];

  @override
  void initState() {
    super.initState();
    _chargerBergeries();
  }

  Future<void> _chargerBergeries() async {
    try {
      final session = CurrentUserService.instance;

      if (!session.isLoggedIn || !session.isClient) {
        setState(() {
          _loading = false;
          _erreur =
          "Vous devez être connecté en tant que client.";
        });
        return;
      }

      final clients =
      await _clientRepository.getClients();

      if (clients.isEmpty) {
        setState(() {
          _loading = false;
          _erreur =
          "Votre compte n'est pas encore associé à une fiche client.";
        });
        return;
      }

      final client = clients.first;

      final bergeries =
      await _bergerieRepository
          .getBergeriesByClient(client.id);

      if (!mounted) return;

      setState(() {
        _bergeries = bergeries
            .where((bergerie) => bergerie.active)
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _erreur =
        "Impossible de récupérer vos bergeries.";
      });
    }
  }

  void _ouvrirBergerie(BergerieModel bergerie) {
    context.push(
      '/moutons/add',
      extra: bergerie,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/dashboard/admin');
          },
        ),
        title: const Text("Choisir une bergerie"),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_erreur != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 64,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 20),
              Text(
                _erreur!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  context.go('/dashboard/admin');
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  "Retour au dashboard",
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_bergeries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_work_outlined,
                size: 72,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 20),
              const Text(
                "Aucune bergerie disponible",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Vous n'avez pas encore de bergerie "
                    "associée à votre compte.\n\n"
                    "Contactez SET'SI SA MBAAR pour "
                    "associer une bergerie à votre compte.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () {
                  context.go('/dashboard/admin');
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  "Retour au dashboard",
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _chargerBergeries,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Choisissez une bergerie",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Sélectionnez la bergerie dans laquelle "
                "vous souhaitez enregistrer votre mouton.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),
          ..._bergeries.map(
                (bergerie) => _buildBergerieCard(
              bergerie,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBergerieCard(
      BergerieModel bergerie,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _ouvrirBergerie(bergerie),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.home_work_rounded,
                  color: Colors.green,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      bergerie.nom,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (bergerie.adresse.isNotEmpty)
                      Text(
                        bergerie.adresse,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (bergerie.telephone.isNotEmpty)
                      Text(
                        bergerie.telephone,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}