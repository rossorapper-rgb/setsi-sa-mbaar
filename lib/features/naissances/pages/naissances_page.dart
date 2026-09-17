import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/current_bergerie_config.dart';
import '../../../core/session/current_user_service.dart';
import '../../gestation/models/gestation_model.dart';
import '../../gestation/repositories/firebase_gestation_repository.dart';

class NaissancesPage extends StatefulWidget {
  const NaissancesPage({super.key});

  @override
  State<NaissancesPage> createState() => _NaissancesPageState();
}

class _NaissancesPageState extends State<NaissancesPage> {
  final _repository = FirebaseGestationRepository();
  final _searchController = TextEditingController();

  List<GestationModel> _naissances = [];
  bool _loading = true;
  String _recherche = '';

  Color get _primary => CurrentBergerieConfig.instance.config.couleurPrimaire;
  Color get _orange => CurrentBergerieConfig.instance.config.couleurSecondaire;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      if (mounted) setState(() => _recherche = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final all = await _repository.getGestations();
      final result = all.where((g) => g.miseBasEffectuee || g.statut == 'Terminée').toList();
      if (mounted) setState(() => _naissances = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de charger les naissances : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<GestationModel> get _filtered {
    if (_recherche.isEmpty) return _naissances;
    return _naissances.where((g) {
      return g.nomFemelle.toLowerCase().contains(_recherche) ||
          g.belierNom.toLowerCase().contains(_recherche) ||
          g.observations.toLowerCase().contains(_recherche);
    }).toList();
  }

  Future<void> _openBirth( GestationModel naissance) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _NaissanceDetailsDialog(
        naissance: naissance,
        primary: _primary,
        orange: _orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = CurrentBergerieConfig.instance.config;
    final compact = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text('Naissances — ${config.nomBergerie}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard/bergerie'),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F8FC),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.all(compact ? 14 : 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _primary.withValues(alpha: .12)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: _orange.withValues(alpha: .12),
                    child: Icon(Icons.child_friendly_rounded, color: _orange, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Naissances enregistrées', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('${_naissances.length} mise(s) bas dans votre élevage', style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une mère ou une observation…',
                prefixIcon: Icon(Icons.search_rounded, color: _primary),
                suffixIcon: _recherche.isEmpty
                    ? null
                    : IconButton(icon: const Icon(Icons.clear), onPressed: _searchController.clear),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filtered.isEmpty)
              _EmptyState(primary: _primary)
            else
              ..._filtered.map((naissance) => _NaissanceCard(
                    naissance: naissance,
                    primary: _primary,
                    orange: _orange,
                    onTap: () => _openBirth(naissance),
                  )),
          ],
        ),
      ),
    );
  }
}

class _NaissanceCard extends StatelessWidget {
  const _NaissanceCard({
    required this.naissance,
    required this.primary,
    required this.orange,
    required this.onTap,
  });

  final GestationModel naissance;
  final Color primary;
  final Color orange;
  final VoidCallback onTap;

  String _date(DateTime? date) {
    if (date == null) return 'Date inconnue';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final photo = naissance.photoUrl;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 68,
                  height: 68,
                  color: primary.withValues(alpha: .08),
                  child: photo == null || photo.isEmpty
                      ? Icon(Icons.photo_camera_back_rounded, color: primary, size: 30)
                      : Image.network(photo, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image_rounded, color: primary)),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(naissance.nomFemelle.isEmpty ? 'Mère sans nom' : naissance.nomFemelle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(_date(naissance.dateMiseBas), style: TextStyle(color: primary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('${naissance.nombreAgneaux} agneau(x) • ${naissance.nombreMales} mâle(s) • ${naissance.nombreFemelles} femelle(s) • ${naissance.nombreMortNes} mort(s)-né(s)', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: orange),
            ],
          ),
        ),
      ),
    );
  }
}

class _NaissanceDetailsDialog extends StatelessWidget {
  const _NaissanceDetailsDialog({required this.naissance, required this.primary, required this.orange});

  final GestationModel naissance;
  final Color primary;
  final Color orange;

  String _date(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Fiche de naissance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primary))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              if (naissance.photoUrl != null && naissance.photoUrl!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(naissance.photoUrl!, width: double.infinity, height: 260, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 16),
              _Info('Mère', naissance.nomFemelle),
              _Info('Date de mise bas', _date(naissance.dateMiseBas)),
              _Info('Total agneaux', '${naissance.nombreAgneaux}'),
              _Info('Mâles', '${naissance.nombreMales}'),
              _Info('Femelles', '${naissance.nombreFemelles}'),
              _Info('Mort-nés', '${naissance.nombreMortNes}'),
              _Info('Observations', naissance.observations.isEmpty ? 'Aucune' : naissance.observations),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: orange),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: RichText(text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
          TextSpan(text: '$label : ', style: const TextStyle(fontWeight: FontWeight.w800)),
          TextSpan(text: value),
        ])),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            Icon(Icons.child_friendly_rounded, size: 54, color: primary.withValues(alpha: .45)),
            const SizedBox(height: 12),
            const Text('Aucune naissance enregistrée', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Les mises bas enregistrées depuis Gestations apparaîtront ici.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          ],
        ),
      );
}
