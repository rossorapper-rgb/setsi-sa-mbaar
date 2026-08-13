import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/current_user_service.dart';
import '../../bergeries/models/bergerie_model.dart';
import '../../bergeries/repository/firebase_bergerie_repository.dart';
import '../models/mouton_model.dart';
import '../repository/firebase_mouton_repository.dart';
import 'mouton_details_page.dart';

class MesMoutonsPage extends StatefulWidget {
  const MesMoutonsPage({super.key});

  @override
  State<MesMoutonsPage> createState() => _MesMoutonsPageState();
}

class _MesMoutonsPageState extends State<MesMoutonsPage> {
  final FirebaseBergerieRepository _bergerieRepository =
  FirebaseBergerieRepository();

  final FirebaseMoutonRepository _moutonRepository =
  FirebaseMoutonRepository();

  bool _loading = true;
  List<BergerieModel> _bergeries = [];
  List<MoutonModel> _moutons = [];
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _erreur = null;
      });
    }

    try {
      final utilisateur = CurrentUserService.instance.currentUser;

      if (utilisateur == null) {
        throw Exception("Utilisateur connecté introuvable.");
      }

      final bergeries = await _bergerieRepository.getAllBergeries();
      final List<MoutonModel> moutons = [];

      // Anciens moutons associés à une bergerie.
      for (final bergerie in bergeries) {
        final liste = await _moutonRepository.getMoutonsByBergerie(
          bergerie.id,
        );
        moutons.addAll(liste);
      }

      // Moutons du compte, y compris ceux sans bergerie.
      final tousLesMoutons = await _moutonRepository.getMoutons();
      final ids = moutons.map((mouton) => mouton.id).toSet();

      for (final mouton in tousLesMoutons) {
        if (!ids.contains(mouton.id)) {
          moutons.add(mouton);
        }
      }

      if (!mounted) return;

      setState(() {
        _bergeries = bergeries;
        _moutons = moutons;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _erreur = e.toString();
      });
    }
  }

  String _nomBergerie(String bergerieId) {
    if (bergerieId.trim().isEmpty) {
      return "Aucune bergerie associée";
    }

    final bergerie = _bergeries.where(
          (element) => element.id == bergerieId,
    );

    if (bergerie.isEmpty) {
      return "Bergerie inconnue";
    }

    return bergerie.first.nom;
  }

  Color _couleurSexe(String sexe) {
    return sexe.toLowerCase() == "femelle"
        ? Colors.pink
        : Colors.blue;
  }

  IconData _iconeSexe(String sexe) {
    return sexe.toLowerCase() == "femelle"
        ? Icons.female
        : Icons.male;
  }

  Future<void> _ouvrirDetails(MoutonModel mouton) async {
    final resultat = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MoutonDetailsPage(mouton: mouton),
      ),
    );

    if (!mounted) return;

    if (resultat == true) {
      _charger();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard/admin'),
        ),
        title: const Text("Mes moutons"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _charger,
            tooltip: "Actualiser",
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erreur != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                "Impossible de charger vos moutons.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _erreur!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _charger,
                icon: const Icon(Icons.refresh),
                label: const Text("Réessayer"),
              ),
            ],
          ),
        ),
      );
    }

    if (_moutons.isEmpty) {
      return RefreshIndicator(
        onRefresh: _charger,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 140),
            Icon(Icons.pets_outlined, size: 70, color: Colors.grey),
            SizedBox(height: 20),
            Center(
              child: Text(
                "Aucun mouton enregistré.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                "Vos moutons apparaîtront ici.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _charger,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildStats(),
          const SizedBox(height: 24),
          _buildMoutonsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mes moutons",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          "Consultez les moutons de votre compte.",
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final femelles = _moutons
        .where((mouton) => mouton.sexe.toLowerCase() == "femelle")
        .length;

    final males = _moutons.where((mouton) {
      final sexe = mouton.sexe.toLowerCase();
      return sexe == "male" || sexe == "mâle";
    }).length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: "Total",
            value: _moutons.length.toString(),
            icon: Icons.pets,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: "Femelles",
            value: femelles.toString(),
            icon: Icons.female,
            color: Colors.pink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: "Mâles",
            value: males.toString(),
            icon: Icons.male,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildMoutonsList() {
    return Column(
      children: _moutons.map((mouton) {
        final couleur = _couleurSexe(mouton.sexe);

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: couleur.withValues(alpha: 0.12),
              child: Icon(
                _iconeSexe(mouton.sexe),
                color: couleur,
              ),
            ),
            title: Text(
              mouton.nom,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                "${mouton.numeroIdentification}\n"
                    "${_nomBergerie(mouton.bergerieId)}",
              ),
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _ouvrirDetails(mouton),
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
